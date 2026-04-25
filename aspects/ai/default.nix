# aspects/ai/default.nix - AI services configuration aggregator
{pkgs, ...}: {
  imports = [
    ./llama-cpp.nix
  ];

  environment.systemPackages = with pkgs; [
    llama-cpp
    llmfit
    lmstudio
  ];
}
