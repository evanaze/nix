# aspects/ai/default.nix - AI services configuration aggregator
{pkgs, ...}: {
  imports = [];

  environment.systemPackages = with pkgs; [
    llmfit
    lmstudio
    pi-coding-agent
    # python312Packages.huggingface-hub
    # vllm
  ];

  # services.llama-cpp = {
  #   enable = true;
  #   package = pkgs.llama-cpp.override {
  #     cudaSupport = true;
  #     rocmSupport = false;
  #     metalSupport = false;
  #     # Enable BLAS for optimized CPU layer performance (OpenBLAS)
  #     # blasSupport = true;
  #   };
  # };
}
