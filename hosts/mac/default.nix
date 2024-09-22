{
  pkgs,
  username,
  ...
}: {
  imports = [../shared.nix];

  users.users.${username} = {
    home = "/Users/" + username;
    shell = pkgs.zsh;
  };

  homebrew = {
    enable = true;
  };

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment = {
    variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };

  environment.pathsToLink = ["/share/zsh"];

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  programs.zsh.enable = true;

  system.stateVersion = 4;

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
