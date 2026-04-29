{
  pkgs,
  config,
  ...
}: {
  environment.systemPackages = with pkgs; [
    llmfit
    lmstudio
    pi-coding-agent
    # python312Packages.huggingface-hub
    # vllm
  ];

  services.llama-cpp = {
    enable = true;
    port = 8723;
    extraFlags = [
      "-m"
      "/var/lib/llama-cpp/models/Qwen3.6-35B-A3B-UD-Q3_K_S.gguf"
    ];
    package = pkgs.llama-cpp.override {
      cudaSupport = true;
      rocmSupport = false;
      metalSupport = false;
    };
  };

  services.llama-swap = {
    enable = true;
    port = 8724;
  };
}
