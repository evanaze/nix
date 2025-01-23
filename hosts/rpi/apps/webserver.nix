{pkgs, ...}: let
  domain = "evanazevedo.com";
in {
  environment.systemPackages = with pkgs; [
    nss
  ];

  services.caddy = {
    enable = true;
    email = "me@evanazevedo.com";
    virtualHosts."localhost:80".extraConfig = ''
      root * /var/www/${domain}
      encode gzip

      file_server {
        hide .git
      }
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
