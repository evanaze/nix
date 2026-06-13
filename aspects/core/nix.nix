# aspects/core/nix.nix - Nix settings, flakes, unfree packages, cache pushing
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
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  nixpkgs.config.allowUnfree = true;

  environment = {
    variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
    pathsToLink = ["/share/zsh"];
  };
}
