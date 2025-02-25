{username, ...}: {
  home-manager.users.${username} = {
    slippi-launcher = {
      enable = true;
      isoPath = "/home/evanaze/Games/melee_patched.iso";
      launchMeleeOnPlay = false;
    };
  };

  hardware.opengl.enable = true;

  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTRS{idVendor}=="057e", ATTRS{idProduct}=="0337", MODE="0666"
  '';
}
