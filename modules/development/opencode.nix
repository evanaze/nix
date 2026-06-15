let
  module = {
    username,
    inputs,
    pkgs,
    ...
  }: {
    nixpkgs.overlays = [inputs.openviking.overlays.default];

    environment.systemPackages = with pkgs; [
      ov-cli
      inputs.self.packages.${system}.oh-my-opencode
    ];

    home-manager.users.${username} = {
      home.file.".openviking/ovcli.conf" = {
        text = ''
          {"url": "https://memory.spitz-pickerel.ts.net"}
        '';
      };

      home.file.".openviking/ovcli.settings.conf" = {
        text = ''
          {"language": "en"}
        '';
      };

      programs.opencode = {
        enable = true;
        tui.theme = "catppuccin";
        settings = {
          autoupdate = true;
          lsp = true;
          plugin = ["openviking-opencode"];
          compaction = {
            auto = true;
            prune = true;
            reserved = 8000;
          };
          provider = {
            llama-local = {
              name = "Llama Swap";
              npm = "@ai-sdk/openai-compatible";
              options = {
                baseURL = "https://llm.spitz-pickerel.ts.net:8724/v1";
              };
              models = {
                "gemma-4-12b-q4" = {
                  name = "gemma-4-12b-q4";
                  limit = {
                    context = 64000;
                    output = 4096;
                  };
                };
                "qwen3.6-35b-a3b" = {
                  name = "qwen3.6-35b-a3b";
                  limit = {
                    context = 64000;
                    output = 4096;
                  };
                };
              };
            };
          };
        };
      };
    };
  };
in {
  flake.modules.nixos = {
    developmentOpencode = module;
    development = module;
  };
}
