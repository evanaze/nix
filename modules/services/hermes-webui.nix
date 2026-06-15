let
  module = {
  lib,
  pkgs,
  inputs,
  ...
}: let
  hermes-webui = pkgs.callPackage ../../pkgs/hermes-webui {};
in {
  users.users.hermes.extraGroups = ["evanaze"];

  systemd.services.hermes-webui = {
    after = [
      "hermes-agent.service"
      "tailscaled.service"
    ];
    wants = ["hermes-agent.service"];
    wantedBy = ["multi-user.target"];
    description = "Hermes WebUI - browser interface for Hermes Agent";
    environment = {
      HERMES_HOME = "/mnt/eye/appdata/hermes/.hermes";
      HERMES_WEBUI_CHAT_BACKEND = "gateway";
      HERMES_WEBUI_GATEWAY_BASE_URL = "http://127.0.0.1:8642";
      HERMES_WEBUI_GATEWAY_API_KEY = "d156d12d681eb34356045688a43ba9487764e8731b946ce68d65aebb899324e6";
      HERMES_WEBUI_AGENT_DIR = "${inputs.hermes-agent.outPath}";
    };
    serviceConfig = {
      Type = "simple";
      User = "hermes";
      Restart = "on-failure";
      RestartSec = "10s";
    };
    script = "${lib.getExe hermes-webui}";
  };

  systemd.services.hermes-tsserve = {
    after = [
      "hermes-webui.service"
      "tailscaled.service"
    ];
    wants = [
      "hermes-webui.service"
      "tailscaled.service"
    ];
    wantedBy = ["multi-user.target"];
    description = "Publish Hermes WebUI via Tailscale Serve";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = "${lib.getExe pkgs.tailscale} serve --service=svc:agent --https=4430 8787";
  };
};
in {
  flake.modules.nixos = {
    servicesHermesWebui = module;
    services = module;
  };
}
