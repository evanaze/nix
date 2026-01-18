{
  pkgs,
  username,
  ...
}: {
  imports = [
    ./docker.nix
    ./zsh.nix
  ];

  environment.systemPackages = with pkgs; [
    cachix
    cron
    devenv
    dig
    expect
    git
    htop
    lsof
    meslo-lgs-nf
    nmap
    tree
    unzip
    wget
  ];

  # Set your time zone.
  time.timeZone = "America/Denver";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
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

  ## Garbage collector
  programs.nh = {
    enable = true;
    flake = "/home/${username}/.config/nix";
    clean = {
      enable = true;
      extraArgs = "--keep-since 7d --keep 3";
    };
  };

  system = {
    # Auto upgrade
    autoUpgrade = {
      enable = true;
      allowReboot = true;
      # Daily 00:00
      dates = "daily UTC";
    };
  };

  nix.extraOptions = ''
    trusted-users = root ${username}
  '';

  nixpkgs.config.allowUnfree = true;

  environment = {
    variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
    pathsToLink = ["/share/zsh"];
  };

  sops = {
    defaultSopsFile = ../../secrets.yaml;
    age.keyFile = "home/${username}/.config/sops/age/keys.txt";
  };

  programs.zsh.enable = true;

  services.tailscale.enable = true;
}
