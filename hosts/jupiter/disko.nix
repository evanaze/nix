{username, ...}: {
  disko.devices = {
    disk = {
      main = {
        device = "/dev/sda";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              type = "EF00";
              size = "1G";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = ["umask=0077"];
              };
            };
            cryptkey = {
              size = "32M";
              content = {
                type = "luks";
                name = "cryptkey";
                settings = {
                  allowDiscards = true;
                };
              };
            };
            swap = {
              size = "32G";
              content = {
                type = "luks";
                name = "cryptswap";
                settings = {
                  allowDiscards = true;
                  keyFile = "/dev/mapper/cryptkey";
                };
                content = {
                  type = "swap";
                  randomEncryption = false;
                };
              };
            };
            root = {
              size = "100%";
              content = {
                type = "luks";
                name = "cryptroot";
                settings = {
                  allowDiscards = true;
                  keyFile = "/dev/mapper/cryptkey";
                };
                content = {
                  type = "zfs";
                  pool = "nvme-pool";
                };
              };
            };
          };
        };
      };
    };

    zpool = {
      nvme-pool = {
        type = "zpool";
        options = {
          autotrim = "on";
          ashift = "12";
        };
        rootFsOptions = {
          compression = "on";
          mountpoint = "none";
          "com.sun:auto-snapshot" = "false";
        };

        datasets = {
          # Nix store - no snapshots needed
          "local/nix" = {
            type = "zfs_fs";
            options = {
              mountpoint = "legacy";
              "com.sun:auto-snapshot" = "false";
            };
            mountpoint = "/nix";
          };

          # Root filesystem
          "system/root" = {
            type = "zfs_fs";
            options = {
              mountpoint = "legacy";
              "com.sun:auto-snapshot" = "true";
            };
            mountpoint = "/";
          };

          # Var - needs posixacl for systemd journal
          "system/root/var" = {
            type = "zfs_fs";
            options = {
              mountpoint = "legacy";
              acltype = "posixacl";
              xattr = "sa";
              "com.sun:auto-snapshot" = "true";
            };
            mountpoint = "/var";
          };

          # Home directories
          "user/home" = {
            type = "zfs_fs";
            options = {
              mountpoint = "legacy";
              "com.sun:auto-snapshot" = "true";
            };
            mountpoint = "/home";
          };

          "user/home/${username}" = {
            type = "zfs_fs";
            options = {
              mountpoint = "legacy";
              "com.sun:auto-snapshot" = "true";
            };
            mountpoint = "/home/${username}";
          };

          # Reserved space for ZFS over-provisioning
          reserved = {
            type = "zfs_fs";
            options = {
              mountpoint = "none";
              reservation = "100G";
              quota = "100G";
              "com.sun:auto-snapshot" = "false";
            };
          };
        };
      };
    };
  };
}
