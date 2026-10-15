let
  module = {pkgs, ...}: {
    environment.systemPackages = [pkgs.folo];

    services.rsshub = {
      enable = true;
      redis = {
        enable = true;
        createLocally = false;
        host = "127.0.0.1";
        port = 6379;
      };
    };

    systemd.services.rsshub = {
      after = ["redis-default.service"];
      requires = ["redis-default.service"];
    };
  };
in {
  flake.modules.nixos = {
    servicesRssHub = module;
    services = module;
  };
}
