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
      hideRawDevice = false;
    };
  };

  # Disable wifi and bluetooth before suspend to reduce battery draw in sleep
  # systemd.services.preparesleep = {
  #   enable = true;
  #   wantedBy = ["sleep.target"];
  #   before = ["sleep.target"];
  #   description = "Disable wifi and bluetooth before suspend to reduce battery draw in sleep";
  #   serviceConfig = {
  #     Type = "oneshot";
  #     ExecStart = "${pkgs.util-linux}/bin/rfkill block bluetooth wlan";
  #     ExecStop = "${pkgs.util-linux}/bin/rfkill unblock bluetooth wlan";
  #   };
  # };
}
