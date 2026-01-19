{
  pkgs,
  username,
  ...
}: {
  imports = [
    ./apps
    ./hardware-configuration.nix
    ./nvidia.nix
    ../shared
    ../shared/pc
  ];

  networking.hostName = "earth";

  # Bootloader
  boot = {
    kernelModules = ["coretemp"];
    kernelPackages = pkgs.linuxPackages_latest;
  };

  nix.nixPath = [
    "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos"
    "nixos-config=$HOME/.config/nix/hosts/earth"
    "/nix/var/nix/profiles/per-user/root/channels"
  ];

  programs.steam.enable = true;

  # Needed for Obsidian
  nixpkgs.config.permittedInsecurePackages = ["electron-25.9.0"];

  # Set permissions for /dev/hidraw8, i.e. Voyager keyboard
  services.udev.extraRules = ''
    SUBSYSTEM=="hidraw", KERNEL=="hidraw8", MODE="0666"
  '';

  system.stateVersion = "23.11";
}
