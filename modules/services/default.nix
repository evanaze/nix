{
  flake.modules.nixos.services = {
    services.tailscale.extraUpFlags = [
      "--advertise-tags=tag:home-server"
    ];
    services.tailscale.extraSetFlags = [
      "--advertise-exit-node"
      "--accept-dns=false"
    ];
  };
}
