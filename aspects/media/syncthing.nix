{
  lib,
  pkgs,
  username,
  ...
}: {
  services.syncthing = {
    enable = true;
    openDefaultPorts = false;
    guiPasswordFile = "/run/secrets/hs-admin-pass";
    settings = {
      gui = {
        user = "admin";
      };
      devices = {
        "earth" = {
          id = "DEVICE-ID-GOES-HERE";
        };
        "jupiter" = {
          id = "DEVICE-ID-GOES-HERE";
        };
      };
      folders = {
        "Documents" = {
          path = "/home/${username}/Documents";
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
