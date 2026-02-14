{
  lib,
  pkgs,
  username,
  ...
}: {
  services.syncthing = {
    enable = true;
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
          # id = "/run/secrets/syncthing-earth-id";
          id = "PG2GD3S-2QH7I2X-2SMHKFF-3SKFGKW-CRFFXHI-QFVKWLM-SDG7PFM-WX2V7QB";
        };
        "jupiter" = {
          addresses = ["tcp://100.114.214.80:22000"];
          # id = "/run/secrets/syncthing-jupiter-id";
          id = "XAGP47U-NMVPKUO-FA43ZCU-YND4BUB-DQRRSYO-IIIENIJ-7ZJL34Y-BIZMXQ3";
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
  #   script = "${lib.getExe pkgs.tailscale} serve --service=svc:docs --https=443 8384";
  # };
}
