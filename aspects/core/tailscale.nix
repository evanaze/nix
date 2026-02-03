# aspects/core/tailscale.nix - Tailscale VPN service
{...}: {
  services.tailscale = {
    enable = true;
    openFirewall = true;
    authKeyFile = "/run/secrets/ts-server-key";
    extraSetFlags = [
      "--ssh"
    ];
  };
}
