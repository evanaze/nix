let
  module = {config, ...}: {
    networking.firewall = {
      allowedTCPPorts = [6443];
      allowedUDPPorts = [8472];
    };

    sops.secrets.kubernetes = {
      owner = "k3s";
      group = "k3s";
      mode = "0640";
    };

    services.k3s = {
      enable = true;
      role = "server";
      token = config.sops.secrets.kubernetes.path;
      clusterInit = true;
    };

    services.tailscale.serve.services.k8s.endpoints."tcp:443" = "http://localhost:6443";
  };
in {
  flake.modules.nixos = {
    services = module;
    servicesK8sControlPlane = module;
  };
}
