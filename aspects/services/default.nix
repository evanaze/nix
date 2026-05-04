# aspects/services/default.nix - Self hosted apps and services
{...}: {
  imports = [
    ./actual.nix
    ./open-webui.nix
  ];

  services.tailscale = {
    extraSetFlags = [
      "--advertise-exit-node"
    ];
  };
}
