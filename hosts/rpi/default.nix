# hosts/rpi/default.nix - Raspberry Pi 5 host-specific configuration
{
  pkgs,
  lib,
  username,
  ...
}: {
  nix.nixPath = [
    "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos"
    "nixos-config=$HOME/.config/nix/hosts/rpi"
    "/nix/var/nix/profiles/per-user/root/channels"
  ];

  # RPI-specific networking
  # mdns
  systemd.network.networks = {
    "99-ethernet-default-dhcp".networkConfig.MulticastDNS = "yes";
    "99-wireless-client-dhcp".networkConfig.MulticastDNS = "yes";
  };

  # This comment was lifted from `srvos`
  # Do not take down the network for too long when upgrading
  systemd.services = {
    systemd-networkd.stopIfChanged = false;
    systemd-resolved.stopIfChanged = false;
  };

  # Set static IP over ethernet
  networking = {
    hostName = "mercury";
    firewall = {
      enable = true;
      allowedTCPPorts = [80 443];
      allowedUDPPorts = [5353];
    };
    nameservers = [
      "1.1.1.1#one.one.one.one"
      "1.0.0.1#one.one.one.one"
    ];
    interfaces.end0 = {
      ipv4.addresses = [
        {
          address = "192.168.50.150";
          prefixLength = 24;
        }
      ];
    };
    useNetworkd = true;
    defaultGateway = {
      address = "192.168.50.1";
      interface = "end0";
    };
    wireless.enable = false;
    wireless.iwd = {
      enable = true;
      settings = {
        Network = {
          EnableIPv6 = true;
          RoutePriorityOffset = 300;
        };
        Settings.AutoConnect = true;
      };
    };
  };

  services.resolved = {
    enable = true;
    dnssec = "true";
    domains = ["~."];
    fallbackDns = [
      "1.1.1.1#one.one.one.one"
      "1.0.0.1#one.one.one.one"
    ];
    dnsovertls = "true";
  };

  # RPI-specific user configuration
  users = {
    users = {
      root.initialHashedPassword = "";
      ${username} = {
        group = "nixos";
        initialHashedPassword = "";
        isNormalUser = true;
        extraGroups = ["wheel" "networkmanager" "video"];
        shell = pkgs.zsh;
      };
    };
    groups.nixos = {};
  };

  security.polkit.enable = true;
  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  services.getty.autologinUser = username;
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };

  nix.settings.trusted-users = [username];

  system.stateVersion = "24.11";
}
