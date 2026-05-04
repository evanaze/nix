{
  config,
  lib,
  pkgs,
  ...
}: {
  services.open-webui = {
    enable = true;
    port = 8725;
    environment = {
      ENABLE_SIGNUP = "False";
      OPENAI_API_BASE_URL = "http://ai.spitz-pickerel.ts.net:${toString config.services.llama-swap.port}/v1";
    };
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
    script = "${lib.getExe pkgs.tailscale} serve --service=svc:ai --https=${toString config.services.open-webui.port} ${toString config.services.open-webui.port}";
  };
}
