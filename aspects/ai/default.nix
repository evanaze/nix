# aspects/ai/default.nix - AI services configuration aggregator
{pkgs, ...}: {
  imports = [];

  environment.systemPackages = with pkgs; [
    llama-cpp
    llmfit
    lmstudio
    pi-coding-agent
    python312Packages.huggingface-hub
    vllm
  ];
}
