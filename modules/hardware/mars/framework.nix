let
  module = # aspects/hardware/framework.nix - Framework 13 laptop configuration + power management
{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    gnome-power-manager
    powertop
  ];

  # Use latest kernel to fix MT7922 Bluetooth WMT initialization bug (fixed in 6.13+)
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Bootloader kernel params for AMD GPU
  boot.kernelParams = ["amdgpu.abmlevel=0"];

  # Enable bios updates
  services.fwupd.enable = true;

  hardware.bluetooth.enable = true;

  # Enable hardware settings
  hardware.framework = {
    enableKmod = true;
    laptop13.audioEnhancement = {
      enable = true;
      hideRawDevice = true;
    };
  };

  # The audioEnhancement virtual sink defaults to 34.3% volume.
  # This service sets it to 100% after pipewire starts.
  systemd.user.services.framework-speakers-volume = {
    enable = true;
    description = "Set Framework Speakers as default at 100% volume";
    after = ["pipewire.service"];
    bindsTo = ["pipewire.service"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = let
        script = pkgs.writeShellScript "set-framework-volume" ''
          set -euo pipefail

          for i in $(${pkgs.coreutils}/bin/seq 1 10); do
            id=$(${pkgs.pipewire}/bin/pw-cli list-objects Node 2>/dev/null \
              | ${pkgs.gawk}/bin/awk '
                function maybe_print() {
                  if (id != "" && has_name && is_sink) {
                    print id
                    found = 1
                    exit
                  }
                }

                /^[[:space:]]*id [0-9]+, type PipeWire:Interface:Node/ {
                  maybe_print()
                  id = $2
                  sub(/,/, "", id)
                  has_name = 0
                  is_sink = 0
                  next
                }

                /node\.name = "audio_effect\.laptop-convolver"/ { has_name = 1 }
                /media\.class = "Audio\/Sink"/ { is_sink = 1 }

                END {
                  if (!found) {
                    maybe_print()
                  }
                }
            ')
            if [ -n "$id" ]; then
              ${pkgs.wireplumber}/bin/wpctl set-default "$id"
              ${pkgs.wireplumber}/bin/wpctl set-volume "$id" 1.0
              ${pkgs.wireplumber}/bin/wpctl set-mute "$id" 0
              exit 0
            fi
            ${pkgs.coreutils}/bin/sleep 0.5
          done
          exit 1
        '';
      in "${script}";
      Restart = "on-failure";
      RestartSec = 3;
    };
    wantedBy = ["pipewire.service"];
  };
};
in {
  flake.modules.nixos = {
    hardwareMarsFramework = module;
    hardwareMars = module;
  };
}
