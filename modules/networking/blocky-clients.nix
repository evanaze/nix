let
  module = # aspects/networking/blocky-clients.nix - Use blocky on jupiter for DNS
  {lib, ...}: {
    # Route DNS through blocky on jupiter (via tailscale) so the
    # ads/reddit/youtube denylists apply to this machine.
    # Overrides the mkDefault Cloudflare nameservers in core/networking.nix.
    # Falls back to Cloudflare if jupiter/tailscale is unreachable (this
    # also means the block can be bypassed while the fallback is in use).
    networking.nameservers = [
      "100.114.214.80" # jupiter.spitz-pickerel.ts.net
      "1.1.1.1"
    ];
  };
in {
  flake.modules.nixos.networkingBlockyClient = module;
}
