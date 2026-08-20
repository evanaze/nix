let
  module = {...}: {
    services.tailscale = {
      enable = true;
      serve = {
        enable = true;
      };
      openFirewall = true;
      authKeyFile = "/run/secrets/ts-server-key";
      extraSetFlags = [
        "--ssh"
        "--exit-node="
      ];
    };

    sops.secrets.ts-server-key = {};

    systemd.services.tailscale-serve = {
      after = [
        "caddy.service"
        "actual.service"
        "postgresql.service"
        "radicale.service"
        "searx.service"
        "ntfy-sh.service"
        "alertmanager-ntfy.service"
        "jellyfin.service"
        "llama-swap.service"
        "seaweedfs.service"
        "immich-server.service"
        "docker-nocodb.service"
        "hermes-webui.service"
      ];
      wants = [
        "caddy.service"
        "actual.service"
        "postgresql.service"
        "radicale.service"
        "searx.service"
        "ntfy-sh.service"
        "alertmanager-ntfy.service"
        "jellyfin.service"
        "llama-swap.service"
        "seaweedfs.service"
        "immich-server.service"
        "docker-nocodb.service"
        "hermes-webui.service"
      ];
    };
  };
in {
  flake.modules.nixos = {
    coreTailscale = module;
    core = module;
    coreRpi = module;
  };
}
