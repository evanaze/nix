let
  module = {
    inputs,
    lib,
    pkgs,
    system,
    ...
  }: let
    hermes = inputs.hermes-agent.packages.${system};
    hermesDesktop = hermes.desktop.overrideAttrs (old: {
      postFixup =
        (old.postFixup or "")
        + ''
          substituteInPlace $out/share/hermes-desktop/electron/hardening.cjs \
            --replace-fail "const DEFAULT_FETCH_TIMEOUT_MS = 15_000" \
                           "const DEFAULT_FETCH_TIMEOUT_MS = 45_000"
        '';
    });
    hermesWithDesktopCommand = pkgs.symlinkJoin {
      name = "hermes-agent-with-desktop-command";
      paths = [hermes.default];
      postBuild = ''
                rm -f "$out/bin/hermes"
                cat > "$out/bin/hermes" <<'EOF'
        #!${pkgs.runtimeShell}
        if [ "$#" -gt 0 ] && { [ "$1" = "desktop" ] || [ "$1" = "gui" ]; }; then
          shift
          exec ${lib.getExe hermesDesktop} "$@"
        fi
        exec ${lib.getExe hermes.default} "$@"
        EOF
                chmod +x "$out/bin/hermes"
      '';
    };
  in {
    environment.systemPackages = [
      hermesWithDesktopCommand
      hermesDesktop
    ];
  };
in {
  flake.modules.nixos.desktopHermes = module;
}
