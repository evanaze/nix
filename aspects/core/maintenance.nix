# aspects/core/maintenance.nix - Auto-upgrade and garbage collection
{inputs, ...}: {
  # Garbage collector using nh
  programs.nh = {
    enable = true;
    flake = inputs.self.outPath;
    clean = {
      enable = true;
      extraArgs = "--keep-since 7d --keep 3";
    };
  };
}