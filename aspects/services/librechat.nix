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
      cache = true;
      endpoints = {
        custom = [
          {
            apiKey = "\${OPENROUTER_KEY}";
            baseURL = "https://openrouter.ai/api/v1";
            dropParams = ["stop"];
            modelDisplayLabel = "OpenRouter";
            models = {
              default = ["qwen/qwen3.6-27b"];
              fetch = true;
            };
            name = "OpenRouter";
            titleConvo = true;
            titleModule = "";
          }
          {
            apiKey = "boo";
            baseURL = "https://llm.spitz-pickerel.ts-net/v1";
            dropParams = ["stop"];
            modelDisplayLabel = "Llama-Swap";
            models = {
              default = ["qwen/qwen3.6-27b"];
              fetch = true;
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
