{
  config,
  username,
  ...
}: {
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
      addHostsEntries = false;
    };

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
      cleanupUnmanagedProfiles = true;
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

    sabnzbd = {
      enable = true;

      settings = {
        misc = {
          api_key._secret = config.sops.secrets."sabnzbd/api_key".path;
          nzb_key._secret = config.sops.secrets."sabnzbd/nzb_key".path;
        };

        servers = [
          {
            name = "Eweka";
            host = "sslreader.eweka.nl";
            port = 563;
            username._secret = config.sops.secrets."usenet/eweka/username".path;
            password._secret = config.sops.secrets."usenet/eweka/password".path;
            connections = 20;
            ssl = true;
            priority = 0;
            retention = 3000;
          }
          {
            name = "NewsgroupDirect";
            host = "news.newsgroupdirect.com";
            port = 563;
            username._secret = config.sops.secrets."usenet/newsgroupdirect/username".path;
            password._secret = config.sops.secrets."usenet/newsgroupdirect/password".path;
            connections = 10;
            ssl = true;
            priority = 1;
            optional = true;
            backup = true;
          }
        ];
      };
    };

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
}
