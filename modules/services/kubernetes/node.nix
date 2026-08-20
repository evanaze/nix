let
  module = {config, ...}: {
    networking.firewall = {
      allowedTCPPorts = [6443];
      allowedUDPPorts = [8472];
    };

    services.k3s = {
      enable = true;
      role = "agent";
      token = config.sops.secrets.kubernetes.path;
      serverAddr = "https://k8s.spitz-pickerel.ts.net";
    };
  };
in {
  flake.modules.nixos = {
    servicesK8sNode = module;
  };
}
