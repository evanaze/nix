let
  module =
    # aspects/core/tailscale.nix - Tailscale VPN service
    {...}: {
      services.tailscale = {
        enable = true;
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
