{...}: {
  services.caddy = {
    enable = true;
    email = "me@evanazevedo.com";
    virtualHosts."localhost".extraConfig = ''
      respond "Hello, world!"
    '';
  };
}
