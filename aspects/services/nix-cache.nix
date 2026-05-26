{
  config,
  lib,
  pkgs,
  ...
}: {
  services.nix-serve = {
    enable = true;
    secretKeyFile = config.sops.secrets.cache-private-key.path;
  };

  systemd.services.nix-cache-tsserve = {
    after = [
      "tailscaled-autoconnect.service"
      "nix-serve.service"
    ];
    wants = [
      "tailscaled-autoconnect.service"
      "nix-serve.service"
    ];
    wantedBy = ["multi-user.target"];
    description = "Using Tailscale Serve to publish Actual";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = "${lib.getExe pkgs.tailscale} serve --service=svc:cache --https=4436 ${toString config.services.nix-serve.port}";
  };
}
