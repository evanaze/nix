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

  nix = {
    extraOptions = ''
      trusted-users = root ${username}
    '';
    gc = {
      automatic = true;
      interval.Day = 7;
      options = "--delete-older-than 7d";
    };
  };

  environment = {
    variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
    pathsToLink = ["/share/zsh"];
  };
}
