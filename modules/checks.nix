{
  inputs,
  lib,
  ...
}: {
  imports = [inputs.flake-parts.flakeModules.checks];

  flake = {
    checks.x86_64-linux = {
      earth-system = inputs.self.nixosConfigurations.earth.config.system.build.toplevel;
      jupiter-system = inputs.self.nixosConfigurations.jupiter.config.system.build.toplevel;
    };
  };

  perSystem = {pkgs, ...}: {
    checks = let
      formatFiles = [
        ../modules/checks.nix
        ../modules/hosts.nix
        ../modules/ai/llama-swap.nix
        ../modules/hardware/jupiter/llama-models.nix
      ];
      lintFiles = [
        ../modules/checks.nix
        ../modules/ai/llama-swap.nix
        ../modules/hardware/jupiter/llama-models.nix
      ];
      formatFileArgs = lib.concatStringsSep " " (map toString formatFiles);
      lintFileArgs = lib.concatStringsSep " " (map toString lintFiles);
    in {
      nix-format = pkgs.runCommand "nix-format-check" {
        nativeBuildInputs = [pkgs.alejandra];
      } ''
        alejandra --check ${formatFileArgs}
        touch $out
      '';

      nix-unused-code = pkgs.runCommand "nix-deadnix-check" {
        nativeBuildInputs = [pkgs.deadnix];
      } ''
        deadnix --fail ${lintFileArgs}
        touch $out
      '';

      nix-lint = pkgs.runCommand "nix-statix-check" {
        nativeBuildInputs = [pkgs.statix];
      } ''
        for file in ${lintFileArgs}; do
          statix check "$file"
        done
        touch $out
      '';
    };
  };
}
