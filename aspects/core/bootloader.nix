# aspects/core/bootloader.nix - systemd-boot configuration
# Only for x86_64 systems - RPI uses different bootloader
{lib, ...}: {
  boot.loader = {
    systemd-boot.enable = lib.mkDefault true;
    efi.canTouchEfiVariables = lib.mkDefault true;
  };
}
