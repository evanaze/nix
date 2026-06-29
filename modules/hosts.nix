{inputs, ...}: let
  username = "evanaze";

  mkHost = {
    system,
    hostname,
    stateVersion,
    homeStateVersion ? "23.11",
    modules,
    extraModules ? [],
    homeModules ? [],
  }:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      modules =
        [
          {
            _module.args = {
              inherit
                inputs
                username
                hostname
                system
                ;
            };

            networking.hostName = hostname;
            system.stateVersion = stateVersion;
          }

          inputs.home-manager.nixosModules.home-manager
          {
            home-manager.backupFileExtension = "backup";
            home-manager.overwriteBackup = true;
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
          }

          inputs.sops-nix.nixosModules.sops
        ]
        ++ modules
        ++ extraModules;
    };
in {
  flake.nixosConfigurations = {
    earth = mkHost {
      system = "x86_64-linux";
      hostname = "earth";
      stateVersion = "23.11";
      homeStateVersion = "23.11";
      modules = with inputs.self.modules.nixos; [
        aiServer
        backupNutClient
        backupSyncthing
        businessDuckdbClient
        core
        desktop
        desktopHermes
        development
        gaming
        hardware
        hardwareNvidia
        hardwareEarth
        monitoring
        tools
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

    mars = mkHost {
      system = "x86_64-linux";
      hostname = "mars";
      stateVersion = "25.05";
      homeStateVersion = "23.11";
      modules = with inputs.self.modules.nixos; [
        backupSyncthing
        businessDuckdbClient
        core
        desktop
        desktopHermes
        development
        gamingSteam
        hardware
        hardwareMars
        hardwareUsbTethering
        networkingVpn
        monitoring
        tools
      ];
      extraModules = [
        inputs.nixos-hardware.nixosModules.framework-13-7040-amd
      ];
    };

    jupiter = mkHost {
      system = "x86_64-linux";
      hostname = "jupiter";
      stateVersion = "25.11";
      homeStateVersion = "23.11";
      modules = with inputs.self.modules.nixos; [
        aiDragonflyGgufClient
        backup
        business
        core
        coreFlakeUpdate
        corePrivateGit
        development
        hardware
        hardwareJupiter
        hardwareJupiterLlamaModels
        media
        monitoring
        prometheus
        prometheusAlertmanager
        monitoringNtfy
        smartctlExporter
        networking
        services
        servicesGlance
        tools
      ];
      extraModules = [
        inputs.hermes-agent.nixosModules.default
        inputs.kestra-nix.nixosModules.kestra
        inputs.nixflix.nixosModules.default
        inputs.openviking.nixosModules.default
      ];
    };
  };
}
