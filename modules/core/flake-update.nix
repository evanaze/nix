{
flake.modules.nixos.coreFlakeUpdate = # aspects/core/flake-update.nix - Flake auto-update with boot loop protection
{pkgs, hostname, username, ...}: {
  systemd.services.flake-update = {
    description = "Update flake inputs, rebuild system, and reboot";
    after = ["network-online.target"];
    wants = ["network-online.target"];
    serviceConfig.Type = "oneshot";
    serviceConfig.User = username;
    path = with pkgs; [git openssh nix coreutils];
    script = ''
      set -euo pipefail
      cd /home/${username}/.config/nix
      git pull
      nix flake update
      git add .
      git commit -m "auto: update flake inputs" || true
      git pull
      git push
      /run/wrappers/bin/sudo -n /run/current-system/sw/bin/nixos-rebuild boot --flake /home/${username}/.config/nix#${hostname}
      /run/wrappers/bin/sudo -n mkdir -p /var/lib/flake-update
      date +%s | /run/wrappers/bin/sudo -n tee /var/lib/flake-update/sentinel > /dev/null
      /run/wrappers/bin/sudo -n reboot
    '';
  };

  systemd.timers.flake-update = {
    description = "Daily flake update timer";
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "daily";
      RandomizedDelaySec = "45min";
    };
  };

  systemd.services.flake-update-boot-check = {
    description = "Verify flake update boot success and handle rollback";
    wantedBy = ["multi-user.target"];
    after = ["basic.target"];
    restartIfChanged = false;
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    path = with pkgs; [nix coreutils];
    script = ''
      sentinel="/var/lib/flake-update/sentinel"
      cleanup_sentinel() {
        rm -f "$sentinel"
        rmdir /var/lib/flake-update 2>/dev/null || true
      }

      if [ ! -f "$sentinel" ]; then
        exit 0
      fi

      sentinel_time=$(cat "$sentinel")
      case "$sentinel_time" in
        ""|*[!0-9]*)
          echo "Ignoring malformed flake-update sentinel: $sentinel_time"
          cleanup_sentinel
          exit 0
          ;;
      esac

      current_time=$(date +%s)
      age=$((current_time - sentinel_time))

      if [ "$age" -lt 0 ]; then
        echo "Ignoring future flake-update sentinel timestamp: $sentinel_time"
        cleanup_sentinel
        exit 0
      fi

      if [ "$age" -ge 900 ]; then
        echo "Ignoring stale flake-update sentinel age: $age seconds"
        cleanup_sentinel
        exit 0
      fi

      echo "Flake update boot check succeeded; clearing sentinel"
      cleanup_sentinel
    '';
  };
};
}
