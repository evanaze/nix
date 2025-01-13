{...}: {
  imports = [
    ./caddy.nix
  ];

  services.github-runners.hs = {
    enable = true;
    url = "https://github.com/evanaze/evanazevedo.com";
    tokenFile = "/home/evanaze/.tokenfile";
  };
}
