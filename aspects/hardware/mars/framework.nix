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
}
