let
  module = {...}: {
  services.redis.servers.twenty = {
    enable = true;
  };
};
in {
  flake.modules.nixos = {
    businessRedis = module;
    business = module;
  };
}
