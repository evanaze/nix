{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    libimobiledevice
    usbmuxd
  ];
}
