# aspects/gaming/slippi.nix - Super Smash Bros Melee Slippi setup
{username, ...}: {
  home-manager.users.${username} = {
    slippi-launcher = {
      enable = true;
      isoPath = "/home/${username}/Games/melee_patched.iso";
      launchMeleeOnPlay = false;
      useNetplayBeta = true;
    };
  };

  hardware.graphics.enable = true;

  # GameCube controller adapter udev rules
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTRS{idVendor}=="057e", ATTRS{idProduct}=="0337", MODE="0666"
  '';
}
