let
  module = {config, ...}: {
    services.tailscale = {
      enable = true;
      openFirewall = true;
      authKeyFile = config.sops.secrets.ts-server-key.path;
      extraSetFlags = [
        "--ssh"
        "--exit-node="
      ];
    };

    sops.secrets.ts-server-key = {};
  };
in {
  flake.modules.nixos = {
    coreTailscale = module;
    core = module;
    coreRpi = module;
  };
}
