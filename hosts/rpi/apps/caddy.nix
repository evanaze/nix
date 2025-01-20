{...}: let
  domain = "evanazevedo.com";
in {
  services.caddy = {
    enable = true;
    agree = true;
    email = "me@evanazevedo.com";
    virtualHosts."${domain}".extraConfig = ''
      root * /var/www/${domain}
      file_server
    '';
  };
}
