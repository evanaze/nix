let
  module = {
    config,
    inputs,
    pkgs,
    ...
  }: {
    nixpkgs.overlays = [inputs.kestra-nix.overlays.default];

    environment.systemPackages = [pkgs.kestra];

    sops.secrets = {
      "kestra/db-password" = {
        owner = "kestra";
      };
      "kestra/encryption-secret-key" = {
        owner = "kestra";
      };
      "kestra/jdbc-secret-key" = {
        owner = "kestra";
      };
    };

    services.kestra = {
      enable = true;
      port = 7398;
      database = {
        createLocally = true;
        passwordFile = config.sops.secrets."kestra/db-password".path;
      };
      encryptionSecretKeyFile = config.sops.secrets."kestra/encryption-secret-key".path;
      jdbcSecretKeyFile = config.sops.secrets."kestra/jdbc-secret-key".path;
    };
  };
in {
  flake.modules.nixos = {
    services = module;
  };
}
