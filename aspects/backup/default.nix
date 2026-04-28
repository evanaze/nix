{...}: {
  imports = [
    ./nut-server.nix
    ./rclone.nix
    ./restic.nix
    ./syncthing.nix
  ];
}
