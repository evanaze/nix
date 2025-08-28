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
  ];

  environment.systemPackages = with pkgs; [
    claude-code
    code-cursor
    google-chrome
    gnome-terminal
    inkscape
    keymapp
    lm_sensors
    protonmail-desktop
    python314
    slack
    xclip
  ];

  # Bootloader.
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

  # Enable networking
  networking = {
    networkmanager.enable = true;
    nameservers = ["1.1.1.1" "1.0.0.1"];
  };

  fonts.packages = with pkgs; [
    iosevka
  ];

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    # Configure keymap in X11
    xkb = {
      layout = "us";
      variant = "";
    };
  };

  services.desktopManager.gnome.enable = true;

  services.displayManager = {
    # Enable automatic login for the user.
    autoLogin.enable = true;
    autoLogin.user = username;
    gdm.enable = true;
  };

  users.users.${username} = {
    initialPassword = "password";
    isNormalUser = true;
    description = "Evan Azevedo";
    extraGroups = ["networkmanager" "wheel"];
    shell = pkgs.zsh;
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
