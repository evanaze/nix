{pkgs, ...}: let
  domain = "evanazevedo.com";
in {
  environment.systemPackages = with pkgs; [
    nss
  ];

  services.tailscale = {
    extraSetFlags = ["--webserver"];
  };

  services.caddy = {
    enable = true;
    email = "me@evanazevedo.com";
    virtualHosts."localhost:80".extraConfig = ''
      bind 127.0.0.1 [::1]
      root * /var/www/${domain}
      encode gzip

      file_server {
        hide .git
      }

      header {
        ?Cache-Control "max-age=1800"
      }
    '';
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/cloudflared 0755 cloudflared cloudflared -"
    "d /var/www/evanazevedo.com 0755 github-runner-hs github-runner-hs -"
  ];

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
