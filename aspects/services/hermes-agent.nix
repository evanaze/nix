{
  inputs,
  lib,
  pkgs,
  config,
  ...
}: {
  nixpkgs.overlays = [inputs.hermes-agent.overlays.default];

  environment.systemPackages = with pkgs; [
    hermes-agent
  ];

  services.hermes-agent = {
    enable = true;
    # documents = ["$HOME/.config/nix"];
    settings = {
      model.default = "deepseek/deepseek-v4-flash";
      memory = {
        provider = "openviking";
      };
      environmentFiles = [config.sops.secrets."hermes/env".path];
      addToSystemPackages = true;
    };
  };

  sops.secrets."hermes/env" = {
    owner = "hermes";
  };

  systemd.services.hermes-dashboard = {
    after = [
      "network-online.target"
      "hermes-agent.service"
    ];
    wants = ["hermes-agent.service"];
    wantedBy = ["multi-user.target"];
    description = "Hermes Agent Web Dashboard";
    serviceConfig = {
      Type = "simple";
      User = "hermes";
      Restart = "on-failure";
      RestartSec = "5s";
    };
    script = "${lib.getExe pkgs.hermes-agent} dashboard --host 127.0.0.1 --port 9119 --no-open --skip-build";
  };

  systemd.services.hermes-tsserve = {
    after = [
      "tailscaled-autoconnect.service"
      "hermes-dashboard.service"
    ];
    wants = [
      "tailscaled-autoconnect.service"
      "hermes-dashboard.service"
    ];
    wantedBy = ["multi-user.target"];
    description = "Using Tailscale Serve to publish Hermes Agent Dashboard";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = "${lib.getExe pkgs.tailscale} serve --service=svc:agent --https=4430 9119";
  };
}
