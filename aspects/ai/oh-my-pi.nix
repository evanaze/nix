# aspects/development/oh-my-pi.nix - Oh-My-Pi AI coding agent
#
# Note: The bix flake's buildBunPackage is designed for packages with
# a specific structure (build/index.js) and uses npm, not bun.lock.
# Oh-My-Pi uses bun.lock and has a different structure, so we provide
# Bun and install oh-my-pi manually.
#
# After rebuilding with this aspect, install oh-my-pi with:
#   bun install -g @oh-my-pi/pi-coding-agent
{
  pkgs,
  username,
  ...
}: {
  # NixOS System Configuration - Add Bun to system packages
  environment.systemPackages = with pkgs; [bun];

  # Home-Manager Configuration
  home-manager.users.${username} = {
    # Bun is available system-wide
    # Oh-My-Pi should be installed globally using: bun install -g @oh-my-pi/pi-coding-agent
  };
}
