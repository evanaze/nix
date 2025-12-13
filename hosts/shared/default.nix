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
    cron
    devenv
    dig
    expect
    git
    htop
    meslo-lgs-nf
    nmap
    tree
    unzip
    wget
  ];

  sops = {
    defaultSopsFile = ../../secrets.yaml;
    age.keyFile = "home/${username}/.config/sops/age/keys.txt";
  };

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
