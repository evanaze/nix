{
  plugins.avante = {
    enable = true;
    settings = {
      provider = "ollama";
      ollama = {
        endpoint = "https://father.spitz-pickerel.ts.net/";
        model = "qwen2.5-coder:14b";
      };
    };
  };
}
