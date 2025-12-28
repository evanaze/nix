{
  nixos-raspberrypi,
  pkgs,
  lib,
  config,
  ...
}: let
  kernelBundle = pkgs.linuxAndFirmware.v6_6_31;
in {
  imports = with nixos-raspberrypi.nixosModules; [
    ./hardware-configuration.nix

    raspberry-pi-5.base
    raspberry-pi-5.page-size-16k
    raspberry-pi-5.display-vc4
    raspberry-pi-5.bluetooth
    ./pi5-configtxt.nix

    ./networking.nix
    ./users.nix
    ../shared

    ./apps
  ];

  # Use the systemd-boot EFI boot loader.
  boot = {
    loader.raspberryPi.firmwarePackage = kernelBundle.raspberrypifw;
    loader.raspberryPi.bootloader = "kernel";
    kernelPackages = kernelBundle.linuxPackages_rpi5;
  };

  nixpkgs.overlays = lib.mkAfter [
    (self: super: {
      # This is used in (modulesPath + "/hardware/all-firmware.nix") when at least
      # enableRedistributableFirmware is enabled
      # I know no easier way to override this package
      inherit (kernelBundle) raspberrypiWirelessFirmware;
      # Some derivations want to use it as an input,
      # e.g. raspberrypi-dtbs, omxplayer, sd-image-* modules
      inherit (kernelBundle) raspberrypifw;
    })
  ];

  nix = {
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
    nixPath = [
      "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos"
      "nixos-config=$HOME/.config/nix/hosts/rpi"
      "/nix/var/nix/profiles/per-user/root/channels"
    ];
  };

  services.udev.extraRules = ''
    # Ignore partitions with "Required Partition" GPT partition attribute
    # On our RPis this is firmware (/boot/firmware) partition
    ENV{ID_PART_ENTRY_SCHEME}=="gpt", \
      ENV{ID_PART_ENTRY_FLAGS}=="0x1", \
      ENV{UDISKS_IGNORE}="1"
  '';

  system.nixos.tags = let
    cfg = config.boot.loader.raspberryPi;
  in [
    "raspberry-pi-${cfg.variant}"
    cfg.bootloader
    config.boot.kernelPackages.kernel.version
  ];
  system.stateVersion = "24.11";
  i18n.defaultLocale = "en_US.UTF-8";
}
