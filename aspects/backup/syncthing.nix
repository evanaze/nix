{
  hostname,
  username,
  ...
}: {
  services.syncthing = {
    enable = true;
    user = username;
    dataDir = "/home/${username}";
    key = "/run/secrets/syncthing/${hostname}/key";
    cert = "/run/secrets/syncthing/${hostname}/cert";
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
            "earth"
            "mars"
            "jupiter"
          ];
        };
        "Downloads" = {
          path = "/home/${username}/Downloads";
          ignorePerms = false;
          devices = [
            "earth"
            "mars"
            "jupiter"
          ];
        };
      };
    };
  };
}
