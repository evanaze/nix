{
  pkgs,
  username,
  ...
}: {
  imports = [
    ../shared.nix
    ./backup.nix
    ./homebrew.nix
  ];

  users.users.${username} = {
    home = "/Users/" + username;
    shell = pkgs.zsh;
  };

  system.stateVersion = 4;
  system.primaryUser = username;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "x86_64-darwin";

  nix = {
    package = pkgs.nix;
    gc = {
      automatic = true;
      interval.Day = 7;
      options = "--delete-older-than 7d";
    };
    settings = {
      experimental-features = "nix-command flakes";
    };
  };
}
