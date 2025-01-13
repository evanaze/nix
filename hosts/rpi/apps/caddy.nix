{...}: {
  services.caddy = {
    enable = true;
    email = "me@evanazevedo.com";
    config = ''
      example.com {
        root /var/www/
      }
    '';
  };
}
