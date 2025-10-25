{
  pkgs,
  inputs,
  ...
}: {
  home.stateVersion = "23.11"; # Please read the comment before changing.

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    # calibre
    cargo
    go
    hugo
    python3
    ripgrep
    thunderbird
    inputs.nixvim.packages.${system}.default
  ];

  programs = {
    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    git = {
      enable = true;
      settings = {
        user = {
          name = "Evan Azevedo";
          email = "me@evanazevdo.com";
        };
        init.defaultBranch = "main";
        pull.rebase = "false";
      };
    };

    ghostty = {
      enable = true;
      enableZshIntegration = true;
      installVimSyntax = true;
      settings = {
        font-family = "Iosevka";
        theme = "Catppuccin Macchiato";
        background-opacity = 0.96;
      };
    };

    zellij = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        theme = "catppuccin-macchiato";
      };
    };

    opencode = {
      enable = true;
      settings = {
        theme = "catppuccin";
        autoupdate = true;
      };
    };
  };
}
