{
  imports = [
    ./pi-coding-agent/default.nix
    ./pi-coding-agent/gondolin.nix
    ./pi-coding-agent/remnic.nix
    ./pi-coding-agent/pi-subagents.nix
  ];

  flake.modules.nixos.development = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      bun
      codex
      nixd
      python313Packages.huggingface-hub
    ];
  };
}
