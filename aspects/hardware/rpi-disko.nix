{...}: {
  disko.devices = {
    disk = {
      main = {
        device = "/dev/mmcblk0";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              device = "/dev/mmcblk0p1"; # Explicit device path
              size = "512M";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot/firmware";
                mountOptions = ["umask=0077"];
              };
            };
            root = {
              device = "/dev/mmcblk0p2"; # Explicit device path
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };
}
