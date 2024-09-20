{
  pkgs,
  inputs,
  ...
}: {
  home.stateVersion = "23.11"; # Please read the comment before changing.

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    cargo
    devenv
    go
    hugo
    nodejs
    python3
    ripgrep
    zellij
    inputs.nixvim.packages.${system}.default
  ];

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.git = {
    enable = true;
    userName = "Evan Azevedo";
    userEmail = "me@evanazevdo.com";
    extraConfig = {
      init.defaultBranch = "main";
    };
  };

  programs.zellij = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      theme = "tokyo-night";
    };
  };
}
