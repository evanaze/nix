# aspects/services/default.nix - Self hosted apps and services
{...}: {
  imports = [
    ./actual.nix
    ./caddy.nix
    ./donetick.nix
    ./hermes-agent.nix
    ./hermes-webui.nix
    ./grafana
    # ./librechat.nix
    ./nix-cache.nix
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
