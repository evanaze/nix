{...}: {
  imports = [
    ./ducklake.nix
    ./postgres.nix
    ./redis.nix
    # ./twenty.nix
    ./seaweedfs.nix
  ];
}
