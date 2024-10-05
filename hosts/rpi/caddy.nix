{...}: {
  services.caddy = {
    enable = true;
    email = me@evanazevedo.com;
  };

  networking.firewall.allowedTCPPorts = [80 443];
}
