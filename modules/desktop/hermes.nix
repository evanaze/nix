let
  module = {
    inputs,
    lib,
    pkgs,
    system,
    ...
  }: let
    hermes = inputs.hermes-agent.packages.${system};
    patchedDesktopNix = builtins.toFile "hermes-desktop-fixed.nix" (
      builtins.replaceStrings
        ["sha256-zi/QMwRZ0+FwE9XTE+DiSIeJXAwxmLKEaBWD5W3pMOI="]
        ["sha256-zOl8rx6woWh7aeRUOlkTMviKc/EAQQX6nr/MxAx1ZPI="]
        (builtins.readFile (inputs.hermes-agent.outPath + "/nix/desktop.nix"))
    );
    hermesDesktop = (pkgs.callPackage patchedDesktopNix {
      inherit (hermes.default.passthru) hermesNpmLib;
      hermesAgent = hermes.default;
    }).overrideAttrs (old: {
      postFixup =
        (old.postFixup or "")
        + ''
          substituteInPlace $out/share/hermes-desktop/dist/electron-main.mjs \
            --replace-fail "var DEFAULT_FETCH_TIMEOUT_MS = 15e3;" \
                           "var DEFAULT_FETCH_TIMEOUT_MS = 45e3;"
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
