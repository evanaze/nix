let
  module = # aspects/gaming/slippi.nix - Super Smash Bros Melee Slippi setup
{
  username,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    usbutils
  ];

  home-manager.users.${username} = {
    slippi-launcher = {
      enable = true;
      isoPath = "/home/${username}/Games/melee_patched.iso";
      launchMeleeOnPlay = false;
      useNetplayBeta = false;
    };
  };

  hardware.graphics.enable = true;

  # Prevent hid-nintendo and hid_mf (Mayflash force-feedback driver) from
  # claiming the GameCube adapter (needs usbhid for Dolphin/Slippi)
  boot.blacklistedKernelModules = ["hid_nintendo" "hid_mf"];

  # GameCube controller adapter udev rules (Nintendo + DragonRise)
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTRS{idVendor}=="057e", ATTRS{idProduct}=="0337", MODE="0666"
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTRS{idVendor}=="0079", ATTRS{idProduct}=="1846", MODE="0666"
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTRS{idVendor}=="0079", ATTRS{idProduct}=="1843", MODE="0666"
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTRS{idVendor}=="0079", ATTRS{idProduct}=="1844", MODE="0666"
  '';
};
in {
  flake.modules.nixos = {
    gamingSlippi = module;
    gaming = module;
  };
}
