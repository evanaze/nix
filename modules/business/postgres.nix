let
  module = {
  pkgs,
  lib,
  ...
}: {
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql;

    identMap = ''
      # ArbitraryMapName systemUser DBUser
         superuser_map      root      postgres
         superuser_map      postgres  postgres
         # Let other names login as themselves
         superuser_map      /^(.*)$   \1
    '';
    authentication = pkgs.lib.mkOverride 10 ''
      #type database    DBuser                   auth-method optional_ident_map
      local all         postgres                 peer        map=superuser_map
      local sameuser    all                      peer        map=superuser_map
      host  all         postgres                 127.0.0.1/32 trust
      host  all         postgres                 ::1/128      trust
      # Allow *arr services to connect via local socket (nixflix)
      local all         sonarr,radarr,lidarr,prowlarr,seerr  trust
    '';
  };

  systemd.services.postgres-tsserve = {
    after = [
      "tailscaled.service"
      "postgresql.service"
    ];
    wants = [
      "tailscaled.service"
      "postgresql.service"
    ];
    wantedBy = ["multi-user.target"];
    description = "Expose PostgreSQL via Tailscale Serve";
    serviceConfig = {
      Type = "exec";
      Restart = "on-failure";
      RestartSec = "10s";
    };
    script = "${lib.getExe pkgs.tailscale} serve --tcp 5432 tcp://localhost:5432";
  };
};
in {
  flake.modules.nixos = {
    businessPostgres = module;
    business = module;
  };
}
