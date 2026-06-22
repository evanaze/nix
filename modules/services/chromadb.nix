let
  module = {
    config,
    lib,
    ...
  }: let
    chromadbPort = 8100;
    chromadbDir = "/mnt/eye/appdata/chromadb";
  in {
    config = lib.mkIf (config.networking.hostName == "jupiter") {
      users.groups.chromadb = {};
      users.users.chromadb = {
        isSystemUser = true;
        group = "chromadb";
        home = chromadbDir;
      };

      services.chromadb = {
        enable = true;
        host = "127.0.0.1";
        port = chromadbPort;
        dbpath = chromadbDir;
        openFirewall = false;
      };

      systemd.services.chromadb = {
        after = [
          "create-appdata-datasets.service"
          "zfs-mount.service"
        ];
        requires = [
          "create-appdata-datasets.service"
          "zfs-mount.service"
        ];
        environment.ANONYMIZED_TELEMETRY = "FALSE";
        serviceConfig = {
          DynamicUser = lib.mkForce false;
          User = "chromadb";
          Group = "chromadb";
          WorkingDirectory = lib.mkForce chromadbDir;
          ReadWritePaths = [chromadbDir];
        };
      };
    };
  };
in {
  flake.modules.nixos = {
    servicesChromadb = module;
    services = module;
  };
}
