{...}: {
  imports = [
    ./gh-actions.nix
    ./samba.nix
    ./tailscale.nix
    ./webserver.nix
  ];
}
