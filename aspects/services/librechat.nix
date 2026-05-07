{
  config,
  lib,
  pkgs,
  ...
}: {
  services.librechat = {
    enable = true;
    env.PORT = 8725;
    enableLocalDB = true;
    meilisearch.enable = true;
  };

  systemd.services.ai-tsserve = {
    after = [
      "tailscaled-autoconnect.service"
      "open-webui.service"
    ];
    wants = [
      "tailscaled-autoconnect.service"
      "open-webui.service"
    ];
    wantedBy = ["multi-user.target"];
    description = "Using Tailscale Serve to publish Open WebUI";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = "${lib.getExe pkgs.tailscale} serve --service=svc:ai --https=${toString config.services.librechat.env.PORT} http://127.0.0.1:4434";
  };
}
