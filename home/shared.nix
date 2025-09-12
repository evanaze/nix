{
  pkgs,
  inputs,
  ...
}: {
  home.stateVersion = "23.11"; # Please read the comment before changing.

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    cargo
    go
    hugo
    python3
    ripgrep
    thunderbird
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
      pull.rebase = "false";
    };
  };

  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    installVimSyntax = true;
    settings = {
      font-family = "Iosevka";
      theme = "catppuccin-macchiato";
      background-opacity = 0.96;
    };
  };

  programs.zellij = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      theme = "catppuccin-macchiato";
    };
  };

  programs.opencode = {
    enable = true;
    settings = {
      theme = "catppuccin";
      autoupdate = true;
    };
  };

  programs.thunderbird = {
    enable = true;
  };
}
