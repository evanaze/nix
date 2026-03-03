{...}: {
  services.postgresql = {
    enable = true;
    ensureDatabases = ["mydatabase"];

    identMap = ''
      # ArbitraryMapName systemUser DBUser
         superuser_map      root      postgres
         superuser_map      postgres  postgres
         # Let other names login as themselves
         superuser_map      /^(.*)$   \1
    '';
  };
}
