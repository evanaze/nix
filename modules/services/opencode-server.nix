{
  flake.modules.nixos.servicesOpencodeServer = {
  lib,
  pkgs,
  username,
  ...
}: {
  home-manager.users.${username}.programs.opencode.settings.plugin = ["openviking-opencode"];

  systemd.services.opencode-server = {
    wantedBy = ["multi-user.target"];
    description = "Hermes Agent Web Dashboard";
    serviceConfig = {
      Type = "simple";
      User = username;
      Restart = "on-failure";
      RestartSec = "5s";
    };
    script = "${lib.getExe pkgs.opencode} serve --hostname 0.0.0.0 --port 4096";
  };

  systemd.services.opencode-tsserve = {
    after = [
      "tailscaled.service"
      "opencode-server.service"
    ];
    wants = [
      "tailscaled.service"
      "opencode-server.service"
    ];
    wantedBy = ["multi-user.target"];
    description = "Using Tailscale Serve to publish Opencode Server";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ${lib.getExe pkgs.tailscale} serve clear svc:opencode || true
      ${lib.getExe pkgs.tailscale} serve --service=svc:opencode --https=443 4096
    '';
  };
};
}
