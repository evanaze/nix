{...}: {
  services.samba = {
    enable = true;
    settings = {
      "tm_share" = {
        "path" = "/mnt/backup";
        "valid users" = "evanaze";
        "public" = "no";
        "writeable" = "yes";
        "force user" = "evanaze";
        "fruit:aapl" = "yes";
        "fruit:time machine" = "yes";
        "vfs objects" = "catia fruit streams_xattr";
      };
    };
  };

  systemd.tmpfiles.rules = [
    "d /mnt/backup 0755 evanaze nixos -"
  ];
}
