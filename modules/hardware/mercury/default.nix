{
  flake.modules.nixos.hardwareMercury = {inputs, ...}: {
  imports = [
    ./hardware-configuration.nix
    inputs.nixos-raspberrypi.nixosModules.raspberry-pi-5.base
    inputs.nixos-raspberrypi.nixosModules.raspberry-pi-5.page-size-16k
    inputs.nixos-raspberrypi.nixosModules.raspberry-pi-5.bluetooth
  ];
};
}
