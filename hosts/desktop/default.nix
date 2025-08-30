{
  pkgs,
  username,
  ...
}: {
  imports = [
    ./apps
    ./hardware-configuration.nix
    ./nvidia.nix
    ../shared.nix
    ../nixos-shared.nix
    ../linux-dev-shared.nix
  ];

  # Bootloader
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelModules = ["coretemp"];
    kernelPackages = pkgs.linuxPackages_latest;
  };

  networking.hostName = "father"; # Define your hostname.

  nix = {
    settings.experimental-features = ["nix-command" "flakes"];
    nixPath = [
      "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos"
      "nixos-config=$HOME/.config/nix/hosts/desktop"
      "/nix/var/nix/profiles/per-user/root/channels"
    ];
  };

  # Enale sudo with no password for user
  security.sudo.extraRules = [
    {
      users = ["${username}"];
      commands = [
        {
          command = "ALL";
          options = ["NOPASSWD"];
        }
      ];
    }
  ];

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  programs.steam.enable = true;

  # Allow unfree packages
  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = ["electron-25.9.0"];
  };

  # Set permissions for /dev/hidraw8
  services.udev.extraRules = ''
    SUBSYSTEM=="hidraw", KERNEL=="hidraw8", MODE="0666"
  '';

  networking.firewall.enable = false;

  system.stateVersion = "23.11";
}
