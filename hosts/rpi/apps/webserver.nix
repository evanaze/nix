{...}: let
  domain = "evanazevedo.com";
in {
  services.caddy = {
    enable = true;
    email = "me@evanazevedo.com";
    virtualHosts."${domain}".extraConfig = ''
      root * /var/www/${domain}
      file_server
    '';
  };

  networking.firewall.allowedTCPPorts = [80 443];

  services.cloudflared = {
    enable = true;
    tunnels = {
      "3c99cee8-ecb7-4274-8b6b-b50df55bc5c5" = {
        credentialsFile = "/home/evanaze/.cloudflared/3c99cee8-ecb7-4274-8b6b-b50df55bc5c5.json";
        ingress = {
          "*.${domain}" = {
            service = "http://localhost:80";
            path = "/*.(jpg|png|css|js)";
          };
        };
        default = "http_status:404";
      };
    };
  };
}
