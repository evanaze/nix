{
  pkgs,
  username,
  ...
}: {
  environment.systemPackages = with pkgs; [
    cron
    devenv
    dig
    expect
    git
    htop
    meslo-lgs-nf
    nmap
    unzip
    vim
    wget
  ];

  programs.zsh.enable = true;

  services.tailscale.enable = true;

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
