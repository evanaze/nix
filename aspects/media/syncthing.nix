{
  hostname,
  username,
  ...
}: {
  services.syncthing = {
    enable = true;
    user = username;
    dataDir = "/home/${username}";
    key = "/run/secrets/syncthing-${hostname}-key-pem";
    cert = "/run/secrets/syncthing-${hostname}-cert-pem";
    openDefaultPorts = true;
    guiPasswordFile = "/run/secrets/admin-pass";
    guiAddress = "127.0.0.1:8384";
    settings = {
      gui = {
        user = "admin";
      };
      devices = {
        "earth" = {
          addresses = ["tcp://100.99.77.56:22000"];
          id = "7Y3UBW3-H2FYEKH-44BQUYC-TJXCAC7-WSMGVEP-GZM5DXK-QV5XPKG-ZBG55AY";
        };
        "jupiter" = {
          addresses = ["tcp://100.114.214.80:22000"];
          id = "HUSB4BP-ISO6UAK-2KL3PND-VQX3OE7-F5ZRFPR-IX7K3UV-Q3UCMFW-34C2XAV";
        };
      };
      folders = {
        "Documents" = {
          path = "/home/${username}/Documents";
          ignorePerms = false;
          devices = [
            "jupiter"
            "earth"
          ];
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [22000];
  # systemd.services.syncthing-tsserve = {
  #   after = [
  #     "tailscaled-autoconnect.service"
  #     "syncthing.service"
  #   ];
  #   wants = [
  #     "tailscaled-autoconnect.service"
  #     "syncthing.service"
  #   ];
  #   wantedBy = ["multi-user.target"];
  #   description = "Using Tailscale Serve to publish Syncthing";
  #   serviceConfig = {
  #     Type = "exec";
  #   };
  #   script = "${lib.getExe pkgs.tailscale} serve --service=svc:sync --https=443 8384";
  # };
}
