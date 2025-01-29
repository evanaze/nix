{...}: {
  services.open-webui = {
    enable = true;
  };

  services.ollama = {
    enable = true;
    port = 11434;
    loadModels = ["deepseek-r1:14b"];
  };
}
