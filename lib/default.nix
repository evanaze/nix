# lib/default.nix - Library entry point
{inputs}: let
  username = "evanaze";
in {
  inherit username;

  # Host builder function
  mkHost = import ./mkHost.nix {inherit inputs username;};

  # Helper to load all nix files from a directory (except default.nix)
  loadAspects = dir: let
    inherit (inputs.nixpkgs) lib;
    files = builtins.readDir dir;
    nixFiles = lib.filterAttrs (name: type: type == "regular" && lib.hasSuffix ".nix" name && name != "default.nix") files;
  in
    map (name: dir + "/${name}") (builtins.attrNames nixFiles);

  # Load all aspects from a category directory including default.nix aggregators
  loadAspectCategory = dir: [dir];
}
