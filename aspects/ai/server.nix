{pkgs, ...}: {
  imports = [./llama-swap.nix];

  environment.systemPackages = with pkgs; [
    llmfit
    lmstudio
    pi-coding-agent
    # python312Packages.huggingface-hub
    # vllm
  ];
}
