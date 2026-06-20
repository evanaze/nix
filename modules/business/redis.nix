let
  module = {...}: {
    services.redis.servers.twenty = {
      enable = true;
      bind = "127.0.0.1";
      port = 6379;
    };
  };
in {
  flake.modules.nixos = {
    businessRedis = module;
    business = module;
  };
}
