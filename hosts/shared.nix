{
  pkgs,
  username,
  ...
}: {
  environment.systemPackages = with pkgs; [
    cron
    devenv
    git
    htop
    meslo-lgs-nf
    nmap
    unzip
    vim
    wget
  ];

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    ipv4 = true;
    ipv6 = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };

  programs.zsh.enable = true;

  sevices.tailscale.enable = true;

  nix.extraOptions = ''
    trusted-users = root ${username}
  '';

  environment = {
    variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
    pathsToLink = ["/share/zsh"];
  };
}
