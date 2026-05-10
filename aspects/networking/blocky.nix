# aspects/networking/blocky.nix - Blocky DNS ad-blocking
{...}: {
  services.blocky = {
    enable = true;
    settings = {
      ports.dns = 53;
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
          #Adblocking
          ads = ["https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"];
          # Custom blocklist for Reddit
          reddit = [
            "reddit.com"
            "www.reddit.com"
            "i.redd.it"
            "redditstatic.com"
          ];
        };
        clientGroupsBlock = {
          default = ["ads"];
          # Create a group for iPhone
          iphone = [
            "ads"
            "reddit"
          ];
        };
      };

      caching = {
        minTime = "5m";
        maxTime = "30m";
        prefetching = true;
      };

      # Client-specific configuration
      clientLookup = {
        # iPhone configuration - replace with actual IP
        clients = {
          iphone = [
            "192.168.1.100"
            "100.74.29.10"
          ];
        };
      };
    };
  };

  networking.firewall = {
    allowedTCPPorts = [53];
    allowedUDPPorts = [53];
  };
}
