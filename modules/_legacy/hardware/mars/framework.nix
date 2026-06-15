# aspects/hardware/framework.nix - Framework 13 laptop configuration + power management
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
    description = "Set Framework Speakers volume to 100%";
    after = ["pipewire.service"];
    bindsTo = ["pipewire.service"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = let
        script = pkgs.writeShellScript "set-framework-volume" ''
          for i in $(seq 1 10); do
            id=$(${pkgs.pipewire}/bin/pw-cli list-objects 2>/dev/null \
              | ${pkgs.gnugrep}/bin/grep -B10 'node.name = "audio_effect.laptop-convolver"' \
              | ${pkgs.gnused}/bin/sed -n 's/.*id \([0-9]*\).*/\1/p')
            if [ -n "$id" ]; then
              ${pkgs.pipewire}/bin/wpctl set-volume "$id" 1.0
              exit 0
            fi
            sleep 0.5
          done
          exit 1
        '';
      in "${script}";
      Restart = "on-failure";
      RestartSec = 3;
    };
    wantedBy = ["pipewire.service"];
  };
}
