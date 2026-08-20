let
  module = {...}: {
    services.tailscale = {
      enable = true;
      serve = {
        enable = true;
        services.paseo.endpoints."tcp:443" = "http://127.0.0.1:6768";
      };
      openFirewall = true;
      authKeyFile = "/run/secrets/ts-server-key";
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
