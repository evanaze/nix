let
  module = {
    config,
    inputs,
    ...
  }: {
    imports = [inputs.kestra-nix.nixosModules.kestra];

    sops.secrets = {
      "kestra/db-password" = {};
      "kestra/encryption-secret-key" = {};
      "kestra/jdbc-secret-key" = {};
    };

    services.kestra = {
      enable = true;
      database = {
        host = "pg.spitz-pickerel.ts.net";
        port = 5432;
        passwordFile = config.sops.secrets."kestra/db-password".path;
      };
      encryptionSecretKeyFile = config.sops.secrets."kestra/encryption-secret-key".path;
      jdbcSecretKeyFile = config.sops.secrets."kestra/jdbc-secret-key".path;
    };
  };
in {
  flake.modules.nixos = {
    servicesKestra = module;
  };
}
