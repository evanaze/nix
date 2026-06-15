{
  flake.modules.nixos.services = {
    services.tailscale.extraSetFlags = [
      "--advertise-exit-node"
      "--accept-dns=false"
    ];
  };
}
