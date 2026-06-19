{inputs, ...}: {
  imports = [ inputs.flake-parts.flakeModules.checks ];

  perSystem = {pkgs, system, ...}: {
    checks = let
      root = ../.;
      rootBuild = "${root}";
      checks = {
        nix-format = pkgs.runCommand "nix-format-check" {
          nativeBuildInputs = [pkgs.alejandra];
        } ''
          alejandra --check ${root}
        '';

        nix-unused-code = pkgs.runCommand "nix-deadnix-check" {
          nativeBuildInputs = [pkgs.deadnix];
        } ''
          deadnix --fail ${root}
        '';

        nix-lint = pkgs.runCommand "nix-statix-check" {
          nativeBuildInputs = [pkgs.statix];
        } ''
          statix check ${root}
        '';
      };
      hostBuilds =
        if system == "x86_64-linux" then
          {
            earth-system = pkgs.runCommand "earth-system-check" {
              nativeBuildInputs = [pkgs.nix];
            } ''
              cd ${rootBuild}
              nix build --no-link .#nixosConfigurations.earth.config.system.build.toplevel
            '';

            jupiter-system = pkgs.runCommand "jupiter-system-check" {
              nativeBuildInputs = [pkgs.nix];
            } ''
              cd ${rootBuild}
              nix build --no-link .#nixosConfigurations.jupiter.config.system.build.toplevel
            '';
          }
        else
          {};
    in if system == "x86_64-linux" then
      checks
      // hostBuilds
    else
      checks;
  };
}
