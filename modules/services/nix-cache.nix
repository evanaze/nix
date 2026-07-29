let
  module = {
    config,
    lib,
    pkgs,
    ...
  }: {
    sops.secrets.cache-private-key = {};

    services.nix-serve = {
      enable = true;
      secretKeyFile = config.sops.secrets.cache-private-key.path;
      package = pkgs.nix-serve-ng;
    };

    networking.firewall.interfaces."tailscale0".allowedTCPPorts = [config.services.nix-serve.port];
  };
in {
  flake.modules.nixos = {
    servicesNixCache = module;
    services = module;
  };
}
