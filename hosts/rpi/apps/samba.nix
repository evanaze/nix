{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    exfat
  ];

  systemd.tmpfiles.rules = [
    "d /mnt/backup 0755 evanaze nixos -"
  ];

  fileSystems."/mnt/backup" = {
    device = "/dev/disk/by-uuid/4f999afe-6114-4531-ba37-4bf4a00efd9e";
    fsType = "exfat";
    options = [
      # If you don't have this options attribute, it'll default to "defaults"
      # boot options for fstab. Search up fstab mount options you can use
      "users" # Allows any user to mount and unmount
      "nofail" # Prevent system from failing if this drive doesn't mount
    ];
  };

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
}
