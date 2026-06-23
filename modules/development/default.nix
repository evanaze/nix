{
  flake.modules.nixos.development = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      bun
      nixd
      codex
    ];
  };
}
