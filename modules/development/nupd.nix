let
  module = {
    pkgs,
    inputs,
    system,
    ...
  }: {
    environment.systemPackages = [
      inputs.self.packages.${system}.nupd
    ];
  };
in {
  flake.modules.nixos = {
    developmentNupd = module;
    development = module;
  };
}
