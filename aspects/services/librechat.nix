{
  config,
  lib,
  pkgs,
  ...
}: {
  services.librechat = {
    enable = true;
    credentials = {
      CREDS_KEY = "/run/secrets/librechat/creds/key";
      CREDS_IV = "/run/secrets/librechat/creds/iv";
      JWT_SECRET = "/run/secrets/librechat/jwt/secret";
      JWT_REFRESH_SECRET = "/run/secrets/librechat/jwt/refresh_secret";
      OPENROUTER_KEY = "/run/secrets/openrouter-api-key";
    };
    env = {
      PORT = 8725;
      ALLOW_PASSWORD_RESET = "true";
      ALLOW_REGISTRATION = "true";
    };
    settings = {
      version = "1.2.0";
      cache = true;
      endpoints = {
        custom = [
          {
            apiKey = "boo";
            baseURL = "https://llm.spitz-pickerel.ts.net:8724/v1";
            dropParams = ["stop"];
            modelDisplayLabel = "Llama-Swap";
            models = {
              default = [
                "gemma-4-e4b-q8"
                "qwen3.6-35b-a3b"
              ];
              fetch = false;
            };
            name = "Llama-Swap";
            titleConvo = true;
            titleModule = "";
          }
        ];
      };
    };
    enableLocalDB = true;
    meilisearch.enable = true;
  };

  services.meilisearch.masterKeyFile = "/run/secrets/librechat/meili/master_key";

  sops.secrets = {
    "librechat/creds/key" = {};
    "librechat/creds/iv" = {};
    "librechat/jwt/secret" = {};
    "librechat/jwt/refresh_secret" = {};
    "librechat/meili/master_key" = {};
    "openrouter-api-key" = {};
  };

  systemd.services.ai-tsserve = {
    after = [
      "tailscaled-autoconnect.service"
      "librechat.service"
    ];
    wants = [
      "tailscaled-autoconnect.service"
      "librechat.service"
    ];
    wantedBy = ["multi-user.target"];
    description = "Using Tailscale Serve to publish LibreChat";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = "${lib.getExe pkgs.tailscale} serve --service=svc:ai --https=4434 http://localhost:${toString config.services.librechat.env.PORT}";
  };
}
