# aspects/services/default.nix - Self hosted apps and services
{...}: {
  imports = [
    ./actual.nix
    ./librechat.nix
  ];

  services.tailscale = {
    extraSetFlags = [
      "--advertise-exit-node"
    ];
  };
}
