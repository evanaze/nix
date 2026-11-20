let
  module = {pkgs, ...}: {
    environment.systemPackages = [pkgs.ethtool];

    systemd.services.link-monitor = {
      script = ''
        ${pkgs.ethtool}/bin/ethtool --show-eee enp4s0 >> /var/log/link-events.log
        ${pkgs.bash}/bin/bash -c '</sys/class/net/enp4s0/carrier || echo "CARRIER LOST at $(date)" >> /var/log/link-events.log'
      '';
      wantedBy = ["network.target"];
    };
  };
in {
  flake.modules.nixos = {
    hardwareEthTool = module;
    hardware = module;
  };
}
