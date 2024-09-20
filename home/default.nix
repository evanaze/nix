{
  pkgs,
  inputs,
  username,
  ...
}: {
  home.stateVersion = "23.11"; # Please read the comment before changing.

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    cargo
    go
    hugo
    nodejs
    python3
    ripgrep
    zellij
    inputs.nixvim.packages.${system}.default
  ];

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
  };
}
