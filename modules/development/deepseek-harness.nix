let
  module = {
    inputs,
    pkgs,
    ...
  }: {
    programs.dsh = {
      enable = true;
      profiles.tui.bundles = [pkgs.dsh.bundles.tui];
      defaultProfile = "nix-tui";
    };
  };
in {
  flake.modules.nixos = {
    developmentDeepseekHarness = module;
    development = module;
  };
}
