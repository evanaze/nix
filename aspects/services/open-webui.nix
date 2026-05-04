{config, ...}: {
  services.open-webui = {
    enable = true;
    port = 8725;
    environment = {
      ENABLE_SIGNUP = "False";
      OPENAI_API_BASE_URL = "http://ai.spitz-pickerel.ts.net:${toString config.services.llama-swap.port}/v1";
    };
  };
}
