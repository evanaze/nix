{...}: {
  services.caddy = {
    enable = true;
    email = "me@evanazevedo.com";
    virtualHosts."evanazevedo.com".extraConfig = ''
      root * /var/www/evanazevedo.com
      respond "Hello, world!"
    '';
  };
}
