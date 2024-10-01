{...}: {
  blocky = {
    enable = true;
  };

  firewall.allowedTCPPorts = [53];
  firewall.allowedUDPPorts = [53];
}
