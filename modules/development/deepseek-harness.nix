let
  module = {
    inputs,
    pkgs,
    username,
    ...
  }: {
    programs.dsh = {
      enable = true;
      profiles.tui.bundles = [pkgs.dsh.bundles.tui];
      defaultProfile = "nix-tui";
    };

    home-manager.users.${username} = {
      home.file.".dsh/settings.yaml".text = ''
        llm-pi-ai:
          providers:
            # Catalog route: endpoint, protocol, and models all come from pi-ai.
            openrouter:
              apiKeyEnv: OPENROUTER_API_KEY

            # Hand-declared route to the local llama gateway.
            llama-local:
              displayName: Llama Swap
              api: openai-completions
              baseURL: https://llm.spitz-pickerel.ts.net/v1
              # The endpoint is a keyless local server; an OpenAI-compatible
              # route still requires either a credential or an Authorization
              # header, so this provides a placeholder the gateway ignores.
              headers:
                Authorization: Bearer local
              compat:
                supportsDeveloperRole: false
                supportsReasoningEffort: false
                maxTokensField: max_tokens
              models:
                - id: gemma-4-12b-q4
                  name: Gemma 4 12B Q4
                  contextWindow: 128000
                  maxTokens: 8192
                - id: lfm2.5-8b-balanced
                  name: LFM 2.5 8B Balanced
                  contextWindow: 128000
                  maxTokens: 8192
                - id: minicpm-v-4.6
                  name: MiniCPM-V 4.6
                  input: [text, image]
                  contextWindow: 8192
                  maxTokens: 4096
                - id: ornith-1.0-9b-q6
                  name: Ornith 1.0 9B Q6_K
                  reasoningEfforts:
                    off:
                    high: high
                  contextWindow: 128000
                  maxTokens: 8192
                - id: qwen3.6-bonsai
                  name: Qwen 3.6 Ternary Bonsai 27B
                  contextWindow: 128000
                  maxTokens: 8192
      '';
    };
  };
in {
  flake.modules.nixos = {
    developmentDeepseekHarness = module;
    # development = module;
  };
}
