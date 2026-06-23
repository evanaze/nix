let
  module = {
    config,
    lib,
    pkgs,
    inputs,
    ...
  }: {
    nixpkgs.overlays = [inputs.kestra-nix.overlays.default];

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
        passwordFile = "/run/secrets/ducklake/db-password";
      };
    };
  };
in {
  flake.modules.nixos = {
    servicesKestra = module;
    services = module;
  };
}
