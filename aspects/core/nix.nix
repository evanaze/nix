# aspects/core/nix.nix - Nix settings, flakes, unfree packages
{username, ...}: {
  nix = {
    extraOptions = "trusted-users = root ${username}";
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
