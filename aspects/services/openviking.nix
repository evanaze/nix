{...}: {
  services.openviking = {
    enable = true;
    readOnlyPaths = [];
    settings = {
      embedding.dense = {
        provider = "openai";
        model = "text-embedding-004";
        api_key = "your-api-key"; # Use sops-nix for security
        api_base = "https://generativelanguage.googleapis.com/v1beta/openai/";
        dimension = 768;
      };
      vlm = {
        provider = "litellm";
        model = "gemini/gemini-2.0-flash";
        api_key = "your-api-key";
      };
    };
  };
}
