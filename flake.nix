{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixvim.url = "github:evanaze/nixvim-conf";
    slippi = {
      url = "github:lytedev/slippi-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    home-manager,
    nixvim,
    nixos-hardware,
    slippi,
    sops-nix,
    ...
  }: let
    username = "evanaze";
  in {
    nixosConfigurations = {
      desktop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit username;
        };
        modules = [
          ./hosts/desktop
          ./modules/slippi.nix

          home-manager.nixosModules.home-manager
          {
            home-manager.backupFileExtension = "backup";
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              inherit inputs;
              inherit username;
            };
            home-manager.users.${username} = {
              imports = [
                ./home/desktop.nix
                slippi.homeManagerModules.default
              ];
            };
          }
          slippi.nixosModules.default
          sops-nix.nixosModules.sops
        ];
      };

      framework = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit username;
        };
        modules = [
          ./hosts/framework

          nixos-hardware.nixosModules.framework-13-7040-amd

          home-manager.nixosModules.home-manager
          {
            home-manager.backupFileExtension = "backup";
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              inherit inputs;
              inherit username;
            };
            home-manager.users.${username} = {
              imports = [
                ./home/framework.nix
              ];
            };
          }
          sops-nix.nixosModules.sops
        ];
      };

      rpi = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = {
          inherit username;
        };
        modules = [
          ./hosts/rpi

          nixos-hardware.nixosModules.raspberry-pi-5

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              inherit inputs;
              inherit username;
            };
            home-manager.users.${username} = import ./home/rpi.nix;
          }
          sops-nix.nixosModules.sops
        ];
      };
    };
  };
}
