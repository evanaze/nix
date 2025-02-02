{...}: {
  services.tailscale = {
    useRoutingFeatures = "server";
    extraSetFlags = ["--webclient" "--advertise-exit-node"];
  };
}
