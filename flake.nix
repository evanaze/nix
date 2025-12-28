{
  description = "NixOS configuration";

  nixConfig = {
    extra-substituters = [
      "https://nixos-raspberrypi.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
    ];
    connect-timeout = 5;
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi/main";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixos-raspberrypi/nixpkgs";
    };
    nixos-anywhere.url = "github:nix-community/nixos-anywhere";
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
    nixos-raspberrypi,
    disko,
    nixos-anywhere,
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

      rpi = nixos-raspberrypi.lib.nixosSystemFull {
        system = "aarch64-linux";
        specialArgs = {
          inherit inputs;
          inherit username;
        };
        modules = [
          ./hosts/rpi

          nixos-hardware.nixosModules.raspberry-pi-5
          disko.nixosModules.disko
          # WARNING: formatting disk with disko is DESTRUCTIVE, check if
          # `disko.devices.disk.nvme0.device` is set correctly!
          ./disko-nvme-zfs.nix
          {networking.hostId = "8821e309";} # NOTE: for zfs, must be unique
          # Further user configuration
          {
            boot.tmp.useTmpfs = true;
          }

          # home-manager.nixosModules.home-manager
          # {
          #   home-manager.useGlobalPkgs = true;
          #   home-manager.useUserPackages = true;
          #   home-manager.extraSpecialArgs = {
          #     inherit inputs;
          #     inherit username;
          #   };
          #   home-manager.users.${username} = import ./home/rpi.nix;
          # }
          # sops-nix.nixosModules.sops
        ];
      };
    };
  };
}
