{
  username,
  config,
  ...
}: {
  home-manager.users.${username}.programs = {
    opencode = {
      enable = true;
      tui.theme = "catppuccin";
      settings = {
        autoupdate = true;
        lsp = true;
        provider = {
          llama-local = {
            name = "Llama Swap";
            npm = "@ai-sdk/openai-compatible";
            options = {
              baseURL = "https://llm.spitz-pickerel.ts.net:${toString config.services.llama-swap.port}/v1";
            };
            models = {
              "gemma-4-e4b-q8" = {
                name = "gemma-4-e4b-q8";
              };
              "qwen3.6-35b-a3b" = {
                name = "qwen3.6-35b-a3b";
              };
            };
          };
        };
      };
    };
  };
}
