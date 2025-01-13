{
  pkgs,
  username,
  ...
}: {
  imports = [
    ../shared.nix
    ./homebrew.nix
  ];

  users.users.${username} = {
    home = "/Users/" + username;
    shell = pkgs.zsh;
  };

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  system.stateVersion = 4;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "x86_64-darwin";
  nix = {
    package = pkgs.nix;
    settings = {
      experimental-features = "nix-command flakes";
    };
  };
}
