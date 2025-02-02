{username, ...}: {
  home-manager.users.${username} = {
    slippi-launcher = {
      enable = true;
      isoPath = "/home/evanaze/Downloads/melee.iso";
      launchMeleeOnPlay = false;
    };
  };

  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTRS{idVendor}=="057e", ATTRS{idProduct}=="0337", MODE="0666"
  '';
}
