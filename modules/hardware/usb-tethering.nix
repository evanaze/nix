{
  flake.modules.nixos.hardwareUsbTethering = {pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    libimobiledevice
    usbmuxd
  ];
};
}
