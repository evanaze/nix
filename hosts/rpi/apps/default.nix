{...}: {
  imports = [
    ./caddy.nix
  ];

  services.github-runners.hs = {
    enable = true;
  };
}
