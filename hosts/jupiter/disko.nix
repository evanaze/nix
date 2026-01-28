{username, ...}: {
  disko.devices = {
    disk = {
      nvme = {
        device = "/dev/disk/by-id/nvme-CT2000P310SSD8_252350A0C5C3";
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

      # HDD pool drives for RAIDZ1
      hdd1 = {
        device = "/dev/disk/by-id/ata-WDC_WD120EAGZ-00CRJB0_WD-B00N465D";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "hdd-pool";
              };
            };
          };
        };
      };
      hdd2 = {
        device = "/dev/disk/by-id/ata-WDC_WD120EAGZ-00CRJB0_WD-B00N73PD";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "hdd-pool";
              };
            };
          };
        };
      };
      hdd3 = {
        device = "/dev/disk/by-id/ata-WDC_WD120EAGZ-00CRJB0_WD-B00NAZ1D";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "hdd-pool";
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

      # HDD pool - RAIDZ1 across 3x 12TB drives (~24TB usable)
      hdd-pool = {
        type = "zpool";
        mode = "raidz";
        options = {
          ashift = "12";
        };
        rootFsOptions = {
          compression = "zstd";
          mountpoint = "none";
          "com.sun:auto-snapshot" = "false";
        };

        datasets = {
          # Media storage (movies, music, etc.)
          media = {
            type = "zfs_fs";
            options = {
              mountpoint = "legacy";
              "com.sun:auto-snapshot" = "true";
            };
            mountpoint = "/storage/media";
          };

          # Backups
          backups = {
            type = "zfs_fs";
            options = {
              mountpoint = "legacy";
              "com.sun:auto-snapshot" = "true";
            };
            mountpoint = "/storage/backups";
          };

          # General data storage
          data = {
            type = "zfs_fs";
            options = {
              mountpoint = "legacy";
              "com.sun:auto-snapshot" = "true";
            };
            mountpoint = "/storage/data";
          };

          # Reserved space for ZFS over-provisioning
          reserved = {
            type = "zfs_fs";
            options = {
              mountpoint = "none";
              reservation = "500G";
              quota = "500G";
              "com.sun:auto-snapshot" = "false";
            };
          };
        };
      };
    };
  };
}
