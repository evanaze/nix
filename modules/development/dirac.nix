let
  diracOverlay = final: prev: {
    dirac = final.callPackage ../../pkgs/dirac {};
  };

  module = {
    pkgs,
    ...
  }: {
    nixpkgs.overlays = [ diracOverlay ];

    environment.systemPackages = with pkgs; [
      dirac
    ];
  };
in {
  flake.modules.nixos = {
    developmentDirac = module;
    development = module;
  };
}