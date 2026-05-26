# aspects/services/default.nix - Self hosted apps and services
{...}: {
  imports = [
    ./actual.nix
    ./donetick.nix
    # ./hermes-agent.nix
    ./grafana
    # ./librechat.nix
    ./nix-cache.nix
    ./openviking.nix
  ];

  services.tailscale = {
    extraSetFlags = [
      "--advertise-exit-node"
      "--accept-dns=false"
    ];
  };
}
