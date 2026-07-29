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

  # No tailscale serve needed — WireGuard already encrypts the tunnel,
  # and the userspace TLS proxy it adds is the download bottleneck.
  # Clients connect directly over plain HTTP to the Tailscale IP.
  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [config.services.nix-serve.port];
};
in {
  flake.modules.nixos = {
    servicesNixCache = module;
    services = module;
  };
}
