# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{pkgs, ...}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    # ./authelia.nix
    ./blocky.nix
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

  # Set static IP over ethernet
  networking = {
    hostname = "hs";
    firewall.enable = true;
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

  networking.firewall.allowedTCPPorts = [22];
  services.openssh = {
    enable = true;
    ports = [22];
    settings = {
      PasswordAuthentication = false;
      AllowUsers = null;
      UseDns = true;
      X11Forwarding = false;
      PermitRootLogin = "no";
    };
  };
  system.stateVersion = "24.11"; # Did you read the comment?
}
