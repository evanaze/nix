# aspects/development/docker.nix - Docker virtualization
{username, ...}: {
  virtualisation.docker = {
    enable = true;
  };

  users.users.${username}.extraGroups = ["docker"];
}
