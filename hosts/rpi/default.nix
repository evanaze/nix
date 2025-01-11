# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{pkgs, ...}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    # ./authelia.nix
    # ./blocky.nix
    # ./caddy.nix
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

  i18n.defaultLocale = "en_US.UTF-8";

  users = {
    mutableUsers = true;

    users = {
      root = {
        hashedPassword = "*";
      };
      evanaze = {
        group = "nixos";
        hashedPassword = "$y$j9T$0PUNfPgT4X7Dy10pAPMIw0$e29wtHpG0H0sM6Qp0j6tdo7zZLrxUQXcmZkxj9Gw0T1";
        isNormalUser = true;
        extraGroups = ["wheel"];
      };
    };

    groups = {
      nixos = {};
    };
  };

  # Set static IP over ethernet
  networking = {
    hostName = "hs";
    firewall.enable = true;
    nameservers = ["1.1.1.1#one.one.one.one" "1.0.0.1#one.one.one.one"];
    interfaces.end0 = {
      ipv4.addresses = [
        {
          address = "192.168.50.150";
          prefixLength = 24;
        }
      ];
    };
    defaultGateway = {
      address = "192.168.50.1";
      interface = "end0";
    };
  };

  services.resolved = {
    enable = true;
    dnssec = "true";
    domains = ["~."];
    fallbackDns = ["1.1.1.1#one.one.one.one" "1.0.0.1#one.one.one.one"];
    dnsovertls = "true";
  };

  system.stateVersion = "24.11"; # Did you read the comment?
}
