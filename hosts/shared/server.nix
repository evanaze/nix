{...}: {
  services.tailscale = {
    useRoutingFeatures = "server";
    authKeyFile = "/run/secrets/ts_server_key";
  };
}
