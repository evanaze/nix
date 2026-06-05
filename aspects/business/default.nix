{...}: {
  imports = [
    ./postgres.nix
    ./redis.nix
    # ./twenty.nix
    ./seaweedfs.nix
    # ./ducklake.nix
  ];
}
