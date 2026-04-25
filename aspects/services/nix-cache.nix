{
  config,
  lib,
  pkgs,
  ...
}: {
  services.nix-serve = {
    enable = true;
    secretKeyFile = "/var/secrets/cache-private-key.pem";
  };

  systemd.services.nix-cache-tsserve = {
    after = [
      "tailscaled-autoconnect.service"
      "nix-serve.service"
    ];
    wants = [
      "tailscaled-autoconnect.service"
      "actual.service"
    ];
    wantedBy = ["multi-user.target"];
    description = "Using Tailscale Serve to publish Actual";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = "${lib.getExe pkgs.tailscale} serve --service=svc:cache --http=${config.services.nix-serve.bindAddress}:${toString config.services.nix-serve.port}";
  };
}
