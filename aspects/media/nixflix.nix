{
  config,
  lib,
  pkgs,
  username,
  ...
}: {
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      rocmPackages.clr.icd
      libva-utils
      libva-vdpau-driver
      libvdpau-va-gl
    ];
  };

  nixflix = {
    enable = true;
    mediaDir = "/mnt/eye/media";
    stateDir = "/mnt/eye/media/.state";
    mediaUsers = [username];

    theme = {
      enable = true;
      name = "overseerr";
    };

    caddy = {
      enable = true;
      domain = "nixflix";
      addHostsEntries = true;
      tls = {
        enable = true;
        internal = true;
      };
    };

    # services.caddy.virtualHosts."http://:${toString caddyPort}" = {
    #   extraConfig = ''
    #     reverse_proxy localhost:${toString searxngPort} {
    #       header_up X-Forwarded-Proto https
    #       header_up X-Forwarded-For {remote_host}
    #       header_up X-Forwarded-Host {host}
    #     }
    #   '';
    # };

    postgres.enable = true;

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
            name = "DrunkenSlug";
            apiKey._secret = config.sops.secrets."indexer-api-keys/DrunkenSlug".path;
          }
          {
            name = "NZBFinder";
            apiKey._secret = config.sops.secrets."indexer-api-keys/NZBFinder".path;
          }
          {
            name = "NzbPlanet";
            apiKey._secret = config.sops.secrets."indexer-api-keys/NzbPlanet".path;
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

  # services.postgresql.dataDir = lib.mkForce "/var/lib/postgresql/17";

  services.caddy.package = lib.mkForce (pkgs.caddy.withPlugins {
    plugins = ["github.com/caddyserver/replace-response@v0.0.0-20250618171559-80962887e4c6"];
    hash = "sha256-bNvQuD8eq5kzRxP96yl1tfE7ro1gW26UEHJeU3TyahU=";
  });

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
    script = "${lib.getExe pkgs.tailscale} serve --service=svc:media --https=4433 8096";
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
    "indexer-api-keys/DrunkenSlug" = {};
    "indexer-api-keys/NZBFinder" = {};
    "indexer-api-keys/NzbPlanet" = {};
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
