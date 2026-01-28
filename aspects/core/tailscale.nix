# aspects/core/tailscale.nix - Tailscale VPN service
{...}: {
  services.tailscale = {
    enable = true;
    openFirewall = true;
    extraSetFlags = [
      "--ssh"
    ];
  };
}
