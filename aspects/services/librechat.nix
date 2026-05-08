{
  config,
  lib,
  pkgs,
  ...
}: {
  services.librechat = {
    enable = true;
    env.PORT = 8725;
    credentials = {
      CREDS_KEY = "/run/secrets/librechat/creds/key";
      CREDS_IV = "/run/secrets/librechat/creds/iv";
      JWT_SECRET = "/run/secrets/librechat/jwt/secret";
      JWT_REFRESH_SECRET = "/run/secrets/librechat/jwt/refresh_secret";
      OPENROUTER_KEY = "/run/secrets/openrouter-api-key";
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
