# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{pkgs, ...}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    # Necessary configuration
    ./networking.nix
    ./users.nix

    # Services
    ./apps/caddy.nix
    ../shared.nix
    ../nixos-shared.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = false;
    };
    kernelPackages = pkgs.linuxPackages_rpi4;
    initrd.systemd.tpm2.enable = false;
  };

  nix = {
    settings.experimental-features = ["nix-command" "flakes"];
    nixPath = [
      "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos"
      "nixos-config=$HOME/.config/nix/hosts/rpi"
      "/nix/var/nix/profiles/per-user/root/channels"
    ];
  };

  system = {
    # Auto upgrade
    autoUpgrade = {
      enable = true;
      allowReboot = true;
      # Daily 00:00
      dates = "daily UTC";
    };
    stateVersion = "24.11";
  };

  i18n.defaultLocale = "en_US.UTF-8";
}
