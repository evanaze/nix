{
  lib,
  modulesPath,
  ...
}: {
  imports = [(modulesPath + "/installer/scan/not-detected.nix")];

  boot.initrd.availableKernelModules = [
    "usb_storage"
    "usbhid"
  ];
  boot.initrd.kernelModules = [];
  boot.kernelModules = [];
  boot.extraModulePackages = [];

  # Filesystems are managed by disko (see disko-nvme-zfs.nix)

  swapDevices = [];
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
