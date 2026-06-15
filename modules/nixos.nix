{
  flake.modules.nixos = {
    aiServer = ./_legacy/ai/server.nix;
    backup = ./_legacy/backup;
    backupNutClient = ./_legacy/backup/nut-client.nix;
    backupSyncthing = ./_legacy/backup/syncthing.nix;
    business = ./_legacy/business;
    businessDuckdbClient = ./_legacy/business/duckdb-client.nix;
    core = ./_legacy/core;
    coreFlakeUpdate = ./_legacy/core/flake-update.nix;
    desktop = ./_legacy/desktop;
    development = ./_legacy/development;
    gaming = ./_legacy/gaming;
    gamingSteam = ./_legacy/gaming/steam.nix;
    hardware = ./_legacy/hardware;
    hardwareEarth = ./_legacy/hardware/earth.nix;
    hardwareJupiter = ./_legacy/hardware/jupiter;
    hardwareMars = ./_legacy/hardware/mars;
    hardwareNvidia = ./_legacy/hardware/nvidia.nix;
    hardwareUsbTethering = ./_legacy/hardware/usb-tethering.nix;
    media = ./_legacy/media;
    monitoring = ./_legacy/monitoring;
    prometheus = ./_legacy/monitoring/prometheus/default.nix;
    smartctlExporter = ./_legacy/monitoring/prometheus/smartctl-exporter.nix;
    networking = ./_legacy/networking;
    networkingVpn = ./_legacy/networking/vpn.nix;
    services = ./_legacy/services;
  };
}
