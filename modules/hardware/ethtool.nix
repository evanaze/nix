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
  # Run this immediately before power-cycling the switch, to capture the exact state:
  #  ```bash
  #  dmesg | tail -50 | grep -iE 'link|igc|carrier|phy|err'
  #  ip link show enp4s0
  #  # if you have ethtool:
  #  ethtool enp4s0
  #  ```
in {
  flake.modules.nixos = {
    hardwareEthTool = module;
    hardware = module;
  };
}
