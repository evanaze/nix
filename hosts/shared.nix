{
  pkgs,
  username,
  ...
}: {
  environment.systemPackages = with pkgs; [
    claude-code
    cron
    devenv
    dig
    expect
    git
    htop
    meslo-lgs-nf
    nmap
    unzip
    wget
  ];

  programs.zsh.enable = true;

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
