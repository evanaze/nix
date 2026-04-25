# aspects/hardware/raspberry-pi.nix - Raspberry Pi 5 configuration
{
  inputs,
  pkgs,
  lib,
  config,
  ...
}: {
  imports = with inputs.nixos-raspberrypi.nixosModules; [
    raspberry-pi-5.base
    raspberry-pi-5.page-size-16k
    raspberry-pi-5.display-vc4
    raspberry-pi-5.bluetooth
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_rpi5;
    tmp.useTmpfs = true;
  };

  services.udev.extraRules = ''
    ENV{ID_PART_ENTRY_SCHEME}=="gpt", \
      ENV{ID_PART_ENTRY_FLAGS}=="0x1", \
      ENV{UDISKS_IGNORE}="1"
  '';

  system.nixos.tags = let
    cfg = config.boot.loader.raspberry-pi;
  in [
    "raspberry-pi-${cfg.variant}"
    cfg.bootloader
    config.boot.kernelPackages.kernel.version
  ];

  i18n.defaultLocale = "en_US.UTF-8";
}
