{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim.url = "github:evanaze/nixvim-conf";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    slippi = {
      url = "github:lytedev/slippi-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    home-manager,
    nix-darwin,
    nixvim,
    sops-nix,
    slippi,
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
          ./modules/zsh.nix
          ./modules/slippi.nix

          sops-nix.nixosModules.sops
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
        ];
      };

      framework = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit username;
        };
        modules = [
          ./hosts/framework
          ./modules/zsh.nix

          sops-nix.nixosModules.sops
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
        ];
      };

      rpi = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = {
          inherit username;
        };
        modules = [
          ./hosts/rpi
          ./modules/zsh.nix

          sops-nix.nixosModules.sops
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
        ];
      };
    };

    darwinConfigurations = {
      cooper = nix-darwin.lib.darwinSystem {
        system = "x86_64-darwin";
        specialArgs = {
          inherit username;
        };
        modules = [
          ./hosts/mac
          ./modules/zsh.nix

          sops-nix.darwinModules.sops
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              inherit inputs;
              inherit username;
            };
            home-manager.users.${username} = import ./home/mac.nix;
          }
        ];
      };
    };
  };
}
