let
  module = {
    inputs,
    pkgs,
    system,
    ...
  }: {
    environment.systemPackages = [
      inputs.self.packages.${system}.dragonfly-gguf-client
    ];
  };
in {
  flake.modules.nixos = {
    aiDragonflyGgufClient = module;
  };
}
