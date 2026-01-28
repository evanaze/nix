# hosts/mars/default.nix - Mars (Framework laptop) host-specific configuration
{...}: {
  networking.hostName = "mars";

  system.stateVersion = "25.05";
}
