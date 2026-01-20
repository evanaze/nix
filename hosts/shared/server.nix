{...}: {
  services.tailscale = {
    useRoutingFeatures = "server";
    authKeyFile = "/run/secrets/ts-server-key";
  };
}
