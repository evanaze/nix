let
  module = {
    pkgs,
    username,
    ...
  }: {
    home-manager.users.${username} = {
      programs.pi-coding-agent = {
        enable = true;
        extraPackages = with pkgs; [
          bun
          nodejs
          mcp-nixos
        ];
        settings = {
          defaultProvider = "llama-local";
          defaultModel = "ornith-1.0-9b-q4";
          enabledModels = [
            "ornith-1.0-9b-q4"
            "qwen3.6-35b-a3b"
            "gemma-4-12b-q4"
          ];
          packages = [
            "npm:pi-subagents"
            "npm:pi-lens"
            "npm:pi-mcp-adapter"
            "npm:pi-intercom"
            "npm:pi-zentui"
            "npm:@gotgenes/pi-permission-system"
            "npm:@hypabolic/pi-hypa"
            "npm:@remnic/cli"
            "npm:@remnic/plugin-pi"
            "npm:@juicesharp/rpiv-ask-user-question"
            "npm:@juicesharp/rpiv-todo"
            "npm:@juicesharp/rpiv-web-tools"
          ];
        };
        models = {
          providers = {
            "llama-local" = {
              api = "openai-completions";
              apiKey = "none";
              baseUrl = "https://llm.spitz-pickerel.ts.net/v1";
              compat = {
                supportsDeveloperRole = false;
                supportsReasoningEffort = false;
              };
              models = [
                {
                  id = "ornith-1.0-9b-q4";
                  name = "Ornith 1.0 9B Q4_K_M";
                  reasoning = true;
                  contextWindow = 128000;
                  maxTokens = 4096;
                }
                {
                  id = "qwen3.6-35b-a3b";
                  name = "Qwen 3.6 35B A3B";
                  contextWindow = 64000;
                  maxTokens = 4096;
                }
                {
                  id = "gemma-4-12b-q4";
                  name = "Gemma 4 12B Q4";
                  contextWindow = 64000;
                  maxTokens = 4096;
                }
              ];
            };
          };
        };
      };
    };
  };
in {
  flake.modules.nixos = {
    developmentPiAgent = module;
    development = module;
  };
}
