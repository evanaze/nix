# aspects/ai/default.nix - AI services configuration aggregator
{...}: {
  imports = [
    ./aider.nix
    ./ollama.nix
  ];
}
