{
  pkgs,
  username,
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
    model = /home/${username}/models/Qwen3.6-35B-A3B-UD-Q3_K_S.gguf;
    extraFlags = [];
    package = pkgs.llama-cpp.override {
      cudaSupport = true;
      rocmSupport = false;
      metalSupport = false;
      # Enable BLAS for optimized CPU layer performance (OpenBLAS)
      # blasSupport = true;
    };
  };
}
