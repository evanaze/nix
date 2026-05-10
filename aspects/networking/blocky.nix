# aspects/networking/blocky.nix - Blocky DNS ad-blocking
{...}: {
  services.blocky = {
    enable = true;
    settings = {
      ports = {
        dns = 53;
        http = 4000;
      };
      upstreams.groups.default = ["https://1.1.1.1/dns-query"];
      # For initially solving DoH/DoT Requests when no system Resolver is available.
      bootstrapDns = {
        upstream = "https://1.1.1.1/dns-query";
        ips = [
          "1.1.1.1"
          "1.0.0.1"
        ];
      };
      blocking = {
        denylists = {
          ads = ["https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"];
          reddit = [
            ''
              reddit.com
              www.reddit.com
              i.redd.it
              redditstatic.com
            ''
          ];
        };
        clientGroupsBlock = {
          default = ["ads"];
          iphone = [
            "ads"
            "reddit"
          ];
        };
      };

      clientLookup = {
        clients = {
          iphone = [
            "192.168.1.100"
            "100.74.29.10"
          ];
        };
      };

      caching = {
        minTime = "5m";
        maxTime = "30m";
        prefetching = true;
      };
    };
  };

  networking.firewall = {
    allowedTCPPorts = [53];
    allowedUDPPorts = [53];
  };
}
