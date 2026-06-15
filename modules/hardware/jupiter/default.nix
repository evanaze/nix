{
  flake.modules.nixos.hardwareJupiter = {config, lib, pkgs, modulesPath, ...}: {
    imports = [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

    boot.initrd.availableKernelModules = [
      "nvme"
      "xhci_pci"
      "ahci"
      "usbhid"
      "usb_storage"
      "sd_mod"
    ];
    boot.initrd.kernelModules = [];
    boot.kernelModules = ["kvm-amd"];
    boot.extraModulePackages = [];

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/7fb04574-9098-4a19-a8d6-098beed657e1";
      fsType = "ext4";
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/36E5-4978";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };

    fileSystems."/mnt/eye" = { device = "eye"; fsType = "zfs"; };
    fileSystems."/mnt/eye/documents" = { device = "eye/documents"; fsType = "zfs"; };
    fileSystems."/mnt/eye/downloads" = { device = "eye/downloads"; fsType = "zfs"; };
    fileSystems."/mnt/eye/media" = { device = "eye/media"; fsType = "zfs"; };
    fileSystems."/mnt/eye/appdata/actual" = { device = "eye/appdata/actual"; fsType = "zfs"; };
    fileSystems."/mnt/eye/appdata/donetick" = { device = "eye/appdata/donetick"; fsType = "zfs"; };
    fileSystems."/mnt/eye/appdata/grafana" = { device = "eye/appdata/grafana"; fsType = "zfs"; };
    fileSystems."/mnt/eye/appdata/chromadb" = { device = "eye/appdata/chromadb"; fsType = "zfs"; };
    fileSystems."/mnt/eye/appdata/odysseus" = { device = "eye/appdata/odysseus"; fsType = "zfs"; };
    fileSystems."/mnt/eye/appdata/hermes" = { device = "eye/appdata/hermes"; fsType = "zfs"; };
    fileSystems."/mnt/eye/appdata/jellyfin" = { device = "eye/appdata/jellyfin"; fsType = "zfs"; };

    swapDevices = [
      {device = "/dev/disk/by-uuid/30b26b23-04fd-4645-b72a-da5c240c030e";}
    ];

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
