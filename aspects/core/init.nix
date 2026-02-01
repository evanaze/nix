# A simple configuration used when bootstraping a new
# device with nixos-anywhere
{
  pkgs,
  lib,
  ...
}: {
  services.openssh.enable = true;

  environment.systemPackages = with pkgs; [
    curl
    git
  ];

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL1JHowRe8oXl5yd8M31D4MCe1qMsJVBynPL9bdCPZuc root@earth"
  ];

  system.stateVersion = "25.11";
}
