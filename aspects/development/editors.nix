# aspects/development/editors.nix - Editors and terminal tools (nixvim, ghostty, zellij)
{
  pkgs,
  inputs,
  username,
  ...
}: {
  # Home-manager editor configuration
  home-manager.users.${username} = {
    home.packages = with pkgs; [
      inputs.nixvim.packages.${stdenv.hostPlatform.system}.default
    ];

    programs = {
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
          advanced_mouse_actions = false;
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
  };
}
