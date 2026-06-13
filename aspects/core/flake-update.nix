# aspects/core/flake-update.nix - Flake auto-update with boot loop protection
{pkgs, username, ...}: {
  systemd.services.flake-update = {
    description = "Update flake inputs, rebuild system, and reboot";
    after = ["network-online.target"];
    wants = ["network-online.target"];
    serviceConfig.Type = "oneshot";
    serviceConfig.User = username;
    path = with pkgs; [nh git nix coreutils];
    script = ''
      set -euo pipefail
      cd /home/${username}/.config/nix
      git pull
      nix flake update
      git add .
      git commit -m "auto: update flake inputs" || true
      git pull
      git push
      nh os boot /home/${username}/.config/nix
      sudo mkdir -p /var/lib/flake-update
      date +%s | sudo tee /var/lib/flake-update/sentinel > /dev/null
      sudo reboot
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
    serviceConfig.Type = "oneshot";
    path = with pkgs; [nix coreutils];
    script = ''
      sentinel="/var/lib/flake-update/sentinel"
      if [ ! -f "$sentinel" ]; then
        exit 0
      fi

      sentinel_time=$(cat "$sentinel")
      current_time=$(date +%s)
      age=$((current_time - sentinel_time))

      if [ "$age" -lt 900 ]; then
        rm -f "$sentinel"
        rmdir /var/lib/flake-update 2>/dev/null || true
      else
        nixos-rebuild switch --rollback
        rm -rf /var/lib/flake-update
        reboot
      fi
    '';
  };
}