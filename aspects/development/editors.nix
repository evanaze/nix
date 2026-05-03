# aspects/development/editors.nix - Editors and terminal tools (nixvim, ghostty, zellij)
{
  pkgs,
  config,
  inputs,
  username,
  system,
  ...
}: let
  nixvim' = inputs.nixvim.legacyPackages.${system};
  nvim = nixvim'.makeNixvimWithModule {
    inherit pkgs;
    module = ./nixvim;
  };
in {
  # Home-manager editor configuration
  home-manager.users.${username} = {
    home.packages = [
      nvim
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
        tui.theme = "catppuccin";
        settings = {
          autoupdate = true;
          provider = {
            llama-local = {
              name = "Llama Swap";
              npm = "@ai-sdk/openai-compatible";
              options = {
                baseURL = "http://ai.spitz-pickerel.ts.net:${toString config.services.llama-swap.port}";
              };
              models = {
                "unsloth/Qwen3.5-27B-GGUF" = {
                  name = "Qwen3.5-27B Q4_K_XL";
                };
              };
            };
          };
        };
      };
    };
  };
}
