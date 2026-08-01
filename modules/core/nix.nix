let
  module = # aspects/core/nix.nix - Nix settings, flakes, unfree packages, cache pushing
{
  pkgs,
  username,
  ...
}: let
  cacheHost = "evanaze@jupiter.spitz-pickerel.ts.net";
in {
  nix = {
    extraOptions = ''
      trusted-users = root ${username}
      post-build-hook = ${pkgs.writeShellScript "nix-post-build-hook" ''
        set -eu
        if [ "$(hostname)" = "jupiter" ]; then
          exit 0
        fi
        for p in "$@"; do
          exec sudo -u ${username} nix copy --to ssh://${cacheHost} "$p"
        done
      ''}
    '';
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      # Use jupiter as a binary cache for all hosts (declared here so it's baked
      # into each machine's nix.conf, unlike flake.nix nixConfig which is an
      # untrusted setting and gets ignored during rebuilds).
      extra-substituters = ["http://jupiter.spitz-pickerel.ts.net:5000"];
      extra-trusted-public-keys = ["cache:+h9wYaxp+qMa0hHTTnh3cAPmn1DmvlPDj27dfEh+6kA="];
      connect-timeout = 5;
    };
  };

  nixpkgs.config.allowUnfree = true;

  environment = {
    variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
    pathsToLink = ["/share/zsh"];
  };
};
in {
  flake.modules.nixos = {
    coreNix = module;
    core = module;
    coreRpi = module;
  };
}
