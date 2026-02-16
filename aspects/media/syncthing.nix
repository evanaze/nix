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
    openDefaultPorts = false;
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
        "mars" = {
          addresses = ["tcp://100.96.108.85:22000"];
          id = "WQRGUVJ-TQOHTMX-3A4BCPU-KM4U25U-MRETURY-R377JJA-RUPYHAD-HTXWYQV";
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
        "Movies" = {
          path = "/home/${username}/Movies";
          ignorePerms = false;
          devices = [
            "jupiter"
            "earth"
          ];
        };
        "Music" = {
          path = "/home/${username}/Music";
          ignorePerms = false;
          devices = [
            "jupiter"
            "earth"
          ];
        };
        "Pictures" = {
          path = "/home/${username}/Pictures";
          ignorePerms = false;
          devices = [
            "jupiter"
            "earth"
          ];
        };
      };
    };
  };

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
