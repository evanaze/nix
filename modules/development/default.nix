{
  flake.modules.nixos.development = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      bun
      codex
      nixd
      python313Packages.huggingface-hub
    ];
  };
}
