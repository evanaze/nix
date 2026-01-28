# aspects/ai/aider.nix - Aider AI coding assistant
{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    aider-chat
  ];

  # Environment variables for aider
  environment.variables = {
    OLLAMA_API_BASE = "http://127.0.0.1:11434";
    OLLAMA_CONTEXT_LENGTH = "8192";
  };
}
