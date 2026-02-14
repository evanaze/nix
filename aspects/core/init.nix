# A simple configuration used when bootstraping a new
# device with nixos-anywhere
{pkgs, ...}: {
  services.openssh.enable = true;

  environment.systemPackages = with pkgs; [
    curl
    git
  ];

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL1JHowRe8oXl5yd8M31D4MCe1qMsJVBynPL9bdCPZuc root@earth"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF2s2ATwzViz9BPhGmGZ3xwcr3yw4kiaDHi1AteQ9/6e"
  ];

  system.stateVersion = "25.11";
}
