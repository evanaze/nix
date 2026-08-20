let
  module = {...}: {
    networking.firewall.allowedTCPPorts = [6443];

    services.k3s = {
      enable = true;
      role = "server";
    };
  };
in {
  flake.modules.nixos = {
    servicesK8sNode = module;
  };
}
