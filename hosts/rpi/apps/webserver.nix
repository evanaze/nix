{...}: let
  domain = "evanazevedo.com";
in {
  services.caddy = {
    enable = true;
    email = "me@evanazevedo.com";
    virtualHosts."${domain}:80".extraConfig = ''
      root * /var/www/${domain}
      encode gzip
      file_server {
        hide .git
      }
      tls internal
    '';
  };

  networking.firewall.allowedTCPPorts = [80 443];

  services.cloudflared = {
    enable = true;
    tunnels = {
      "3c99cee8-ecb7-4274-8b6b-b50df55bc5c5" = {
        credentialsFile = "/var/lib/cloudflared/3c99cee8-ecb7-4274-8b6b-b50df55bc5c5.json";
        ingress = {
          "*.${domain}" = "http://localhost:80";
        };
        default = "http_status:404";
      };
    };
  };
}
