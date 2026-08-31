let
  falkordbOverlay = final: prev: {
    pythonPackagesExtensions =
      (prev.pythonPackagesExtensions or [])
      ++ [
        (pyFinal: _pyPrev: {
          falkordb = pyFinal.callPackage ../../pkgs/falkordb/python-client.nix {};
        })
      ];
  };

  module = {pkgs, ...}: {
    nixpkgs.overlays = [falkordbOverlay];

    environment.systemPackages = [
      pkgs.python313Packages.falkordb
    ];
  };
in {
  flake.modules.nixos = {
    developmentFalkordb = module;
    development = module;
  };
}