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
      inherit (inputs.self.nixosConfigurations.jupiter.config.services.hermes-agent.settings.mcp_servers)
        actual
        donetick
        nixos;
      formatFiles = [
        ../modules/checks.nix
        ../modules/hosts.nix
        ../modules/ai/llama-swap.nix
        ../modules/ai/vllm.nix
        ../modules/hardware/jupiter/llama-models.nix
      ];
      lintFiles = [
        ../modules/checks.nix
        ../modules/ai/llama-swap.nix
        ../modules/ai/vllm.nix
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

      hermes-mcp-stdio-commands = pkgs.runCommand "hermes-mcp-stdio-commands-check" {} ''
        [ "${actual.command}" = "${pkgs.nodejs_22}/bin/npx" ]
        [ "${donetick.command}" = "${pkgs.uv}/bin/uvx" ]
        [ "${nixos.command}" = "${pkgs.mcp-nixos}/bin/mcp-nixos" ]
        touch $out
      '';
    };
  };
}
