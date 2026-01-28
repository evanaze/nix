# hosts/earth/default.nix - Earth (Desktop) host-specific configuration
{
  pkgs,
  username,
  ...
}: {
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

  # Needed for Obsidian
  nixpkgs.config.permittedInsecurePackages = ["electron-25.9.0"];

  # udev rules: Voyager keyboard + GameCube controller adapter
  services.udev.extraRules = ''
    SUBSYSTEM=="hidraw", KERNEL=="hidraw8", MODE="0666"
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTRS{idVendor}=="057e", ATTRS{idProduct}=="0337", MODE="0666"
  '';

  # Slippi configuration for home-manager
  home-manager.users.${username} = {
    slippi-launcher = {
      enable = true;
      isoPath = "/home/${username}/Games/melee_patched.iso";
      launchMeleeOnPlay = false;
      useNetplayBeta = true;
    };
  };

  system.stateVersion = "23.11";
}
