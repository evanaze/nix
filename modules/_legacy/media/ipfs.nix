# aspects/media/ipfs.nix - IPFS/Kubo node
{
  config,
  username,
  ...
}: {
  services.kubo = {
    enable = true;
  };

  users.users.${username}.extraGroups = [config.services.kubo.group];
}
