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
      mcp = {
        context7 = {
          type = "remote";
          url = "https://mcp.context7.com/mcp";
          headers = {
            CONTEXT7_API_KEY = "YOUR_API_KEY";
          };
          enabled = true;
        };
      };
    };
  };
}
