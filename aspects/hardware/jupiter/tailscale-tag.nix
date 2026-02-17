{...}: {
  services.tailscale = {
    extraSetFlags = [
      "--advertise-tags=tag:home-server"
    ];
  };
}
