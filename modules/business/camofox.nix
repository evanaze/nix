let
  module = {
    config,
    inputs,
    lib,
    system,
    ...
  }: let
    enableCamofox = false;
    camofoxPort = 9377;
    dataDir = "/mnt/eye/appdata/camofox";

    camoufoxPackages = inputs.camoufox-nix.packages.${system};
    camoufox = camoufoxPackages.camoufox;
    joCamofoxBrowser = camoufoxPackages.jo-camofox-browser;
    camoufoxBin = lib.getExe camoufox;
  in {
    config = lib.mkIf (config.networking.hostName == "jupiter" && enableCamofox) {
      users.groups.camofox = {};
      users.users.camofox = {
        isSystemUser = true;
        group = "camofox";
        home = dataDir;
      };

      systemd.tmpfiles.rules = [
        "d ${dataDir} 0750 camofox camofox -"
        "d ${dataDir}/cache 0750 camofox camofox -"
        "d ${dataDir}/home 0750 camofox camofox -"
      ];

      systemd.services.camofox = {
        description = "Camofox local anti-detection browser API";
        after = ["network.target"];
        wantedBy = ["multi-user.target"];
        environment = {
          CAMOFOX_PORT = toString camofoxPort;
          PORT = toString camofoxPort;
          CAMOUFOX_EXECUTABLE = camoufoxBin;
          CAMOUFOX_EXECUTABLE_PATH = camoufoxBin;
          CAMOFOX_EXECUTABLE = camoufoxBin;
          CAMOFOX_EXECUTABLE_PATH = camoufoxBin;
          HOME = "${dataDir}/home";
          NODE_ENV = "production";
          XDG_CACHE_HOME = "${dataDir}/cache";
        };
        serviceConfig = {
          Type = "simple";
          User = "camofox";
          Group = "camofox";
          WorkingDirectory = dataDir;
          ExecStart = lib.getExe joCamofoxBrowser;
          Restart = "on-failure";
          RestartSec = "10s";
          StateDirectory = "camofox";
          ReadWritePaths = [dataDir];
        };
      };
    };
  };
in {
  flake.modules.nixos = {
    businessCamofox = module;
    business = module;
  };
}
