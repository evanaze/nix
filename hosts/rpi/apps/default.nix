{...}: {
  imports = [
    ./gh-actions.nix
    ./samba.nix
    ./webserver.nix
  ];

  services.tailscale.useRoutingFeatures = "server";
}
