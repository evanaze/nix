let
  module = {
    config,
    username,
    inputs,
    lib,
    pkgs,
    system,
    ...
  }: let
    nocodbEnvFile = config.sops.secrets."nocodb/env".path;
    opencodeWithNocodbEnv = pkgs.symlinkJoin {
      inherit (pkgs.opencode) meta;
      name = "${lib.getName pkgs.opencode}-with-nocodb-env-${lib.getVersion pkgs.opencode}";
      paths = [pkgs.opencode];
      nativeBuildInputs = [pkgs.makeWrapper];
      postBuild = ''
        wrapProgram $out/bin/opencode \
          --run ${lib.escapeShellArg ''
          if [ -f ${lib.escapeShellArg nocodbEnvFile} ]; then
            set -a
            . ${lib.escapeShellArg nocodbEnvFile}
            set +a
          fi
        ''}
      '';
    };
  in {
    sops.secrets."nocodb/env" = {
      owner = username;
      mode = "0400";
    };

    home-manager.users.${username} = {
      programs.opencode = {
        enable = true;
        enableMcpIntegration = true;
        package = opencodeWithNocodbEnv;
        extraPackages = [pkgs.mcp-nixos];
        web.environmentFile = nocodbEnvFile;
        tui.theme = "catppuccin";
        settings = {
          autoupdate = true;
          lsp = true;
          plugin = [];
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
                baseURL = "https://llm.spitz-pickerel.ts.net/v1";
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
