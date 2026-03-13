# aspects/core/maintenance.nix - Auto-upgrade and garbage collection
{
  username,
  inputs,
  ...
}: {
  # Garbage collector using nh
  programs.nh = {
    enable = true;
    flake = "/home/${username}/.config/nix";
    clean = {
      enable = true;
      extraArgs = "--keep-since 7d --keep 3";
    };
  };

  system = {
    autoUpgrade = {
      enable = true;
      flake = inputs.self.outPath;
      flags = ["--commit-lock-file"];
      runGarbageCollection = true;
      allowReboot = true;
      dates = "daily UTC"; # Daily around 00:00
      randomizedDelaySec = "45min";
    };
  };
}
