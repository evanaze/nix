{pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix
    ./sleep.nix
    ../shared
    ../shared/pc
  ];

  networking.hostName = "mars";

  environment.systemPackages = with pkgs; [
    gnome-power-manager
    powertop
  ];

  # Bootloader
  boot.kernelParams = ["amdgpu.abmlevel=0"];

  # Enable bios updates
  services.fwupd.enable = true;
  # Enable hardware settings
  hardware.framework = {
    enableKmod = true;
    laptop13.audioEnhancement = {
      enable = true;
      hideRawDevice = false;
    };
  };

  system.stateVersion = "25.05"; # Did you read the comment?
}
