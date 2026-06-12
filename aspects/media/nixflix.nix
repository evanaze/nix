{
  config,
  lib,
  pkgs,
  username,
  ...
}: let
  ports = {
    sonarr = 8989;
    "sonarr-anime" = 8990;
    radarr = 7878;
    lidarr = 8686;
    prowlarr = 9696;
    sabnzbd = 8080;
    jellyfin = 8096;
    seerr = 5055;
  };
  caddyPorts = {
    sonarr = 8300;
    "sonarr-anime" = 8301;
    radarr = 8302;
    lidarr = 8303;
    prowlarr = 8304;
    sabnzbd = 8305;
    jellyfin = 8307;
    seerr = 8308;
  };
in {
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      rocmPackages.clr.icd
      libva-utils
    ];
  };

  # nixflix hardcodes MetadataPath to /var/lib/jellyfin/metadata but runs with
  # --datadir /mnt/eye/media/.state/jellyfin — ensure the path is traversable
  systemd.tmpfiles.rules = [
    "d /var/lib/jellyfin 0750 ${username} media -"
  ];

  nixflix = {
    enable = true;
    mediaDir = "/mnt/eye/media";
    stateDir = "/mnt/eye/media/.state";
    mediaUsers = [username];

    theme = {
      enable = true;
      name = "overseerr";
    };

    sonarr = {
      enable = true;
      config = {
        apiKey._secret = config.sops.secrets."sonarr/api_key".path;
        hostConfig.password._secret = config.sops.secrets."sonarr/password".path;
      };
    };

    radarr = {
      enable = true;
      config = {
        apiKey._secret = config.sops.secrets."radarr/api_key".path;
        hostConfig.password._secret = config.sops.secrets."radarr/password".path;
      };
    };

    recyclarr = {
      enable = true;
    };

    lidarr = {
      enable = true;
      config = {
        apiKey._secret = config.sops.secrets."lidarr/api_key".path;
        hostConfig.password._secret = config.sops.secrets."lidarr/password".path;
      };
    };

    prowlarr = {
      enable = true;
      config = {
        apiKey._secret = config.sops.secrets."prowlarr/api_key".path;
        hostConfig.password._secret = config.sops.secrets."prowlarr/password".path;
        indexers = [
          {
            name = "NZBFinder";
            apiKey._secret = config.sops.secrets."indexer-api-keys/NZBFinder".path;
          }
        ];
      };
    };

    # sabnzbd = {
    #   enable = true;

    #   settings = {
    #     misc = {
    #       api_key._secret = config.sops.secrets."sabnzbd/api_key".path;
    #       nzb_key._secret = config.sops.secrets."sabnzbd/nzb_key".path;
    #     };

    #     servers = [
    #       {
    #         name = "Eweka";
    #         host = "sslreader.eweka.nl";
    #         port = 563;
    #         username._secret = config.sops.secrets."usenet/eweka/username".path;
    #         password._secret = config.sops.secrets."usenet/eweka/password".path;
    #         connections = 20;
    #         ssl = true;
    #         priority = 0;
    #         retention = 3000;
    #       }
    #       {
    #         name = "NewsgroupDirect";
    #         host = "news.newsgroupdirect.com";
    #         port = 563;
    #         username._secret = config.sops.secrets."usenet/newsgroupdirect/username".path;
    #         password._secret = config.sops.secrets."usenet/newsgroupdirect/password".path;
    #         connections = 10;
    #         ssl = true;
    #         priority = 1;
    #         optional = true;
    #         backup = true;
    #       }
    #     ];
    #   };
    # };

    jellyfin = {
      enable = true;
      apiKey._secret = config.sops.secrets."jellyfin/api_key".path;
      users = {
        admin = {
          mutable = false;
          policy.isAdministrator = true;
          password._secret = config.sops.secrets."jellyfin/admin_password".path;
        };
      };
    };

    seerr = {
      enable = true;
      apiKey._secret = config.sops.secrets."seerr/api_key".path;
    };

    vpn = {
      enable = true;
      wgConfFile = config.sops.secrets."wireguard/conf".path;
      accessibleFrom = ["192.168.1.0/24"];
    };
  };

  systemd.services.seerr-setup.wantedBy = lib.mkForce [];
  systemd.services.seerr-setup.serviceConfig.SuccessExitStatus = [
    "0"
    "1"
  ];
  systemd.services.seerr-user-settings.wantedBy = lib.mkForce [];
  systemd.services.seerr-user-settings.serviceConfig.SuccessExitStatus = [
    "0"
    "1"
  ];
  systemd.services.seerr-jellyfin.wantedBy = lib.mkForce [];
  systemd.services.seerr-jellyfin.serviceConfig.SuccessExitStatus = [
    "0"
    "1"
  ];
  systemd.services.seerr-radarr.wantedBy = lib.mkForce [];
  systemd.services.seerr-radarr.serviceConfig.SuccessExitStatus = [
    "0"
    "1"
  ];
  systemd.services.seerr-sonarr.wantedBy = lib.mkForce [];
  systemd.services.seerr-sonarr.serviceConfig.SuccessExitStatus = [
    "0"
    "1"
  ];
  systemd.services.seerr-libraries.wantedBy = lib.mkForce [];
  systemd.services.seerr-libraries.serviceConfig.SuccessExitStatus = [
    "0"
    "1"
  ];
  # systemd.services.prowlarr-indexers.wantedBy = lib.mkForce [];

  systemd.services.lidarr.serviceConfig.Type = lib.mkForce "exec";

  # services.postgresql.dataDir = lib.mkForce "/var/lib/postgresql/17";

  services.caddy.virtualHosts = builtins.listToAttrs (
    map (name: {
      name = "http://:${toString caddyPorts.${name}}";
      value = {
        extraConfig = ''
          reverse_proxy localhost:${toString ports.${name}} {
            header_up X-Forwarded-Proto https
            header_up X-Forwarded-For {remote_host}
            header_up X-Forwarded-Host {host}
          }
        '';
      };
    }) (builtins.attrNames caddyPorts)
  );

  systemd.services.jellyfin-tsserve = {
    after = [
      "tailscaled-autoconnect.service"
      "jellyfin.service"
    ];
    wants = [
      "tailscaled-autoconnect.service"
      "jellyfin.service"
    ];
    wantedBy = ["multi-user.target"];
    description = "Using Tailscale Serve to publish Jellyfin";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = "${lib.getExe pkgs.tailscale} serve --service=svc:media --https=4433 http://127.0.0.1:${toString caddyPorts.jellyfin}";
  };

  systemd.services.lidarr-tsserve = {
    after = [
      "tailscaled-autoconnect.service"
      "lidarr.service"
    ];
    wants = [
      "tailscaled-autoconnect.service"
      "lidarr.service"
    ];
    wantedBy = ["multi-user.target"];
    description = "Using Tailscale Serve to publish Lidarr";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = "${lib.getExe pkgs.tailscale} serve --service=svc:lidarr --https=4434 http://127.0.0.1:${toString caddyPorts.lidarr}";
  };

  sops.secrets = {
    "sonarr/api_key" = {};
    "sonarr/password" = {};
    "radarr/api_key" = {};
    "radarr/password" = {};
    "lidarr/api_key" = {};
    "lidarr/password" = {};
    "prowlarr/api_key" = {};
    "prowlarr/password" = {};
    "indexer-api-keys/NZBFinder" = {};
    "jellyfin/api_key" = {};
    "jellyfin/admin_password" = {};
    "seerr/api_key" = {};
    "wireguard/conf" = {};
    "sabnzbd/api_key" = {};
    "sabnzbd/nzb_key" = {};
    "usenet/eweka/username" = {};
    "usenet/eweka/password" = {};
    "usenet/newsgroupdirect/username" = {};
    "usenet/newsgroupdirect/password" = {};
  };
}
