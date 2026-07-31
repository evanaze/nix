{
  flake.modules.nixos.networkingVpn = {pkgs, ...}: {
    services.mullvad-vpn = {
      enable = true;
      gui.enable = true;
    };
  };
}
