{
  description = "NixOS configuration - Dendritic Pattern";

  nixConfig = {
    extra-substituters = ["https://cache.spitz-pickerel.ts.net:4436"];
    extra-trusted-public-keys = ["cache:+h9wYaxp+qMa0hHTTnh3cAPmn1DmvlPDj27dfEh+6kA="];
    connect-timeout = 5;
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-anywhere.url = "github:nix-community/nixos-anywhere";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixflix = {
      url = "github:kiriwalawren/nixflix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    openviking = {
      url = "github:Daaboulex/openviking-nix";
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
    hermes-agent = {
      url = "github:NousResearch/hermes-agent";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ghostty = {
      url = "github:ghostty-org/ghostty";
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
        packages.x86_64-linux.twenty =
          inputs.nixpkgs.legacyPackages.x86_64-linux.callPackage ./pkgs/twenty
          {};
        nixosConfigurations = {
          # Earth - Desktop with NVIDIA GPU, gaming, AI services
          earth = mkHost {
            system = "x86_64-linux";
            hostname = "earth";
            stateVersion = "23.11";
            homeStateVersion = "23.11";
            aspects = [
              ./aspects/ai/server.nix
              ./aspects/backup/nut-client.nix
              ./aspects/backup/syncthing.nix
              ./aspects/core
              ./aspects/desktop
              ./aspects/development
              ./aspects/gaming
              ./aspects/hardware
              ./aspects/hardware/nvidia.nix
              ./aspects/hardware/earth.nix
              ./aspects/monitoring
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
              ./aspects/desktop
              ./aspects/development
              ./aspects/gaming/steam.nix
              ./aspects/hardware
              ./aspects/hardware/framework.nix
              ./aspects/hardware/mars
              ./aspects/hardware/usb-tethering.nix
              ./aspects/networking/vpn.nix
              ./aspects/monitoring
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
              ./aspects/business
              ./aspects/core
              ./aspects/development
              ./aspects/hardware
              ./aspects/hardware/jupiter
              ./aspects/media
              ./aspects/monitoring
              ./aspects/monitoring/prometheus/smartctl-exporter.nix
              ./aspects/networking
              ./aspects/services
            ];
            extraModules = [
              inputs.hermes-agent.nixosModules.default
              inputs.nixflix.nixosModules.default
              inputs.openviking.nixosModules.default
            ];
          };
        };
      };
    };
}
