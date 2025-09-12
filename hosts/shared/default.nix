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
    sops
    unzip
    wget
  ];

  programs.zsh.enable = true;

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
}
