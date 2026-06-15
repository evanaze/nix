let
  module = {
  config,
  lib,
  pkgs,
  ...
}: {
  sops.secrets.cache-private-key = {};

  services.nix-serve = {
    enable = true;
    secretKeyFile = config.sops.secrets.cache-private-key.path;
    package = pkgs.nix-serve-ng;
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
    script = ''
      ${lib.getExe pkgs.tailscale} serve clear svc:cache || true
      ${lib.getExe pkgs.tailscale} serve --service=svc:cache --https=443 ${toString config.services.nix-serve.port}
    '';
  };
};
in {
  flake.modules.nixos = {
    servicesNixCache = module;
    services = module;
  };
}
