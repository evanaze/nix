# aspects/services/default.nix - Self hosted apps and services
{...}: {
  imports = [
    ./actual.nix
    ./caddy.nix
    ./donetick.nix
    ./hermes-agent.nix
    ./grafana
    # ./librechat.nix
    ./nix-cache.nix
    ./opencode-server.nix
    ./openviking.nix
    ./searx.nix
  ];

  services.tailscale = {
    extraSetFlags = [
      "--advertise-exit-node"
      "--accept-dns=false"
    ];
  };
}
