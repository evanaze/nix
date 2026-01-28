# mkHost.nix - Host builder function for dendritic configuration
{
  inputs,
  username,
}: {
  # Required parameters
  system,
  hostname,
  # Optional parameters
  aspects ? [],
  extraModules ? [],
  homeModules ? [],
  stateVersion ? "24.11",
  homeStateVersion ? "23.11",
  # Whether to use nixos-raspberrypi for this host
  useRaspberryPi ? false,
  ...
}: let
  pkgs = inputs.nixpkgs.legacyPackages.${system};

  # Build the NixOS system
  nixosSystemFn =
    if useRaspberryPi
    then inputs.nixos-raspberrypi.lib.nixosSystemFull
    else inputs.nixpkgs.lib.nixosSystem;

  # Common home-manager configuration
  homeManagerConfig = {
    home-manager.backupFileExtension = "backup";
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.users.${username} = {
      imports =
        [
          {
            home.stateVersion = homeStateVersion;
            programs.home-manager.enable = true;
          }
        ]
        ++ homeModules;
    };
  };

  # Pass shared args via _module.args instead of specialArgs
  moduleArgs = {
    _module.args = {
      inherit inputs username hostname;
    };
  };

  # Base specialArgs - required for nixos-raspberrypi
  baseSpecialArgs = {
    inherit inputs username;
    nixos-raspberrypi = inputs.nixos-raspberrypi;
  };
in
  nixosSystemFn (
    {
      inherit system;
      modules =
        [
          # Pass args via _module.args
          moduleArgs

          # Home-manager module
          inputs.home-manager.nixosModules.home-manager
          homeManagerConfig

          # sops-nix for secrets
          inputs.sops-nix.nixosModules.sops
        ]
        # All aspect modules
        ++ aspects
        # Host-specific extra modules
        ++ extraModules;
    }
    // (
      if useRaspberryPi
      then {specialArgs = baseSpecialArgs;}
      else {}
    )
  )
