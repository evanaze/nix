{
  pkgs,
  username,
  ...
}: {
  imports = [
    ./docker.nix
    ./locale.nix
    ./networking.nix
    ./sops.nix
    ./ssh.nix
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

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
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

  nix = {
    extraOptions = ''trusted-users = root ${username}'';
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  nixpkgs.config.allowUnfree = true;

  environment = {
    variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
    pathsToLink = ["/share/zsh"];
  };

  programs.zsh.enable = true;

  services.tailscale = {
    enable = true;
    openFirewall = true;
    extraSetFlags = [
      "--auto-update"
      "--ssh"
    ];
  };
}
