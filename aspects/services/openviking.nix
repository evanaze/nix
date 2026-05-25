{
  pkgs,
  config,
  inputs,
  username,
  ...
}: {
  nixpkgs.overlays = [inputs.openviking.overlays.default];

  services.openviking = {
    enable = true;
    readOnlyPaths = ["/home/${username}/Documents"];
    settings = {
      embedding.dense = {
        provider = "openai";
        model = "nvidia/llama-nemotron-embed-vl-1b-v2:free";
        api_key = config.sops.secrets.openrouter-api-key;
        api_base = "https://openrouter.ai/api/v1/chat/completions";
      };
      vlm = {
        provider = "openai";
        model = "google/gemini-embedding-2-preview";
        api_key = config.sops.secrets.openrouter-api-key;
        api_base = "https://openrouter.ai/api/v1/chat/completions";
      };
    };
  };

  environment.systemPackages = with pkgs; [
    openviking
  ];
}
