{...}: {
  services.authelia.instances.main = {
    enable = true;
    secrets = {
      jwtSecretFile = "$HOME/.secrets/JWT_SECRET";
      storageEncryptionKeyFile = "$HOME/.secrets/STORAGE_PASSWORD";
      sessionSecretFile = "$HOME/.secrets/SESSION_SECRET";
    };
    settings = {
      theme = "dark";
      default_redirection_url = "https://evanazevedo.com";

      server = {
        host = "127.0.0.1";
        port = 9091;
      };

      log = {
        level = "debug";
        format = "text";
      };

      authentication_backend = {
        file = {
          path = "/var/lib/authelia-main/users_database.yml";
        };
      };

      access_control = {
        default_policy = "deny";
        rules = [
          {
            domain = ["auth.evanazevedo.com"];
            policy = "bypass";
          }
          {
            domain = ["*.evanazevedo.com"];
            policy = "one_factor";
          }
        ];
      };

      session = {
        name = "authelia_session";
        expiration = "12h";
        inactivity = "45m";
        remember_me_duration = "1M";
        domain = "example.com";
        redis.host = "/run/redis-authelia-main/redis.sock";
      };

      regulation = {
        max_retries = 3;
        find_time = "5m";
        ban_time = "15m";
      };

      storage = {
        local = {
          path = "/var/lib/authelia-main/db.sqlite3";
        };
      };

      notifier = {
        disable_startup_check = false;
        filesystem = {
          filename = "/var/lib/authelia-main/notification.txt";
        };
      };
    };
  };
  services.redis.servers.authelia-main = {
    enable = true;
    user = "authelia-main";
    port = 0;
    unixSocket = "/run/redis-authelia-main/redis.sock";
    unixSocketPerm = 600;
  };

  services.caddy.virtualHosts."auth.evanazevedo.com" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:9091";
      proxyWebsockets = true;
    };
  };
}
