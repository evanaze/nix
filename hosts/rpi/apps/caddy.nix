{...}: let
  domain = "evanazevedo.com";
in {
  services.caddy = {
    enable = true;
    email = "me@evanazevedo.com";
    virtualHosts."${domain}:2019".extraConfig = ''
      root * /var/www/${domain}
      file_server
    '';
  };
}
