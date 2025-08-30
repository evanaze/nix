{
  pkgs,
  username,
  ...
}: {
  environment.systemPackages = with pkgs; [
    bitwarden-desktop
    claude-code
    code-cursor
    google-chrome
    gnome-terminal
    inkscape
    keymapp
    protonmail-desktop
    python314
    slack
    xclip
  ];

  # Enable networking
  networking = {
    networkmanager.enable = true;
    nameservers = ["1.1.1.1" "1.0.0.1"];
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
}
