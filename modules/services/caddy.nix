let
  module = {...}: {
  services.caddy = {
    enable = true;
  };
};
in {
  flake.modules.nixos = {
    servicesCaddy = module;
    services = module;
  };
}
