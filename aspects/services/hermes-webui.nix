{
  lib,
  pkgs,
  config,
  inputs,
  ...
}: let
  hermes-webui = pkgs.callPackage ../../pkgs/hermes-webui {};
in {
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
}

