{...}: {
  # Set static IP over ethernet
  networking = {
    hostName = "hs";
    firewall = {
      enable = true;
      allowedTCPPorts = [80 443];
    };
    nameservers = ["1.1.1.1#one.one.one.one" "1.0.0.1#one.one.one.one"];
    interfaces.end0 = {
      ipv4.addresses = [
        {
          address = "192.168.50.150";
          prefixLength = 24;
        }
      ];
    };
    defaultGateway = {
      address = "192.168.50.1";
      interface = "end0";
    };
  };

  services.resolved = {
    enable = true;
    dnssec = "true";
    domains = ["~."];
    fallbackDns = ["1.1.1.1#one.one.one.one" "1.0.0.1#one.one.one.one"];
    dnsovertls = "true";
  };
}
