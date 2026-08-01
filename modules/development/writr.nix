let
  module = {pkgs, inputs, system, ...}: {
    environment.systemPackages = [
      inputs.self.packages.${system}.writr
    ];
  };
in {
  flake.modules.nixos = {
    developmentWritr = module;
    development = module;
  };
}
