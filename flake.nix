{
  description = "NixOS configuration - Dendritic Pattern";

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

    flake-parts.url = "github:hercules-ci/flake-parts";

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

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      flake = let
        lib = import ./lib {inherit inputs;};
        inherit (lib) mkHost username;
      in {
        nixosConfigurations = {
          # Earth - Desktop with NVIDIA GPU, gaming, AI services
          earth = mkHost {
            system = "x86_64-linux";
            hostname = "earth";
            stateVersion = "23.11";
            homeStateVersion = "23.11";
            aspects = [
              ./aspects/backup/nut-client.nix
              ./aspects/backup/syncthing.nix
              ./aspects/core
              ./aspects/shell
              ./aspects/desktop
              ./aspects/media
              ./aspects/development
              ./aspects/gaming
              ./aspects/ai
              ./aspects/hardware/nvidia.nix
              ./aspects/hardware/earth.nix
            ];
            extraModules = [
              inputs.nixos-hardware.nixosModules.common-pc
              inputs.nixos-hardware.nixosModules.common-pc-ssd
              inputs.nixos-hardware.nixosModules.common-cpu-intel-cpu-only

              inputs.slippi.nixosModules.default
            ];
            homeModules = [
              inputs.slippi.homeManagerModules.default
            ];
          };

          # Mars - Framework 13 laptop
          mars = mkHost {
            system = "x86_64-linux";
            hostname = "mars";
            stateVersion = "25.05";
            homeStateVersion = "23.11";
            aspects = [
              ./aspects/backup/syncthing.nix
              ./aspects/core
              ./aspects/shell
              ./aspects/desktop
              ./aspects/development
              ./aspects/gaming
              ./aspects/hardware/framework.nix
              ./aspects/hardware/mars.nix
              ./aspects/networking/vpn.nix
            ];
            extraModules = [
              inputs.nixos-hardware.nixosModules.framework-13-7040-amd
            ];
          };

          # Jupiter - Aoostar NAS Server
          jupiter = mkHost {
            system = "x86_64-linux";
            hostname = "jupiter";
            stateVersion = "25.11";
            homeStateVersion = "23.11";
            aspects = [
              ./aspects/backup
              ./aspects/core
              ./aspects/shell
              ./aspects/development
              ./aspects/hardware/jupiter
              # ./aspects/media
            ];
            extraModules = [
              inputs.disko.nixosModules.disko
              (
                {lib, ...}: {
                  services.syncthing.settings.folders = {
                    "Documents".path = lib.mkForce "/mnt/eye/documents";
                    "Downloads".path = lib.mkForce "/mnt/eye/downloads";
                    "Movies".path = lib.mkForce "/mnt/eye/movies";
                    "Music".path = lib.mkForce "/mnt/eye/music";
                    "Pictures".path = lib.mkForce "/mnt/eye/pictures";
                  };
                }
              )
            ];
          };

          # Raspberry Pi 5
          rpi = mkHost {
            system = "aarch64-linux";
            hostname = "mercury";
            stateVersion = "24.11";
            homeStateVersion = "23.11";
            useRaspberryPi = true;
            aspects = [
              ./aspects/core/rpi.nix
              ./aspects/shell
              ./aspects/networking/blocky.nix
              ./aspects/hardware/raspberry-pi.nix
            ];
            extraModules = [
              inputs.nixos-hardware.nixosModules.raspberry-pi-5
              inputs.disko.nixosModules.disko
              ./hosts/rpi/disko-nvme-zfs.nix
              {networking.hostId = "8821e309";}
            ];
          };
        };
      };
    };
}
