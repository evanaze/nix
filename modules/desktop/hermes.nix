let
  module = {
    inputs,
    lib,
    pkgs,
    system,
    ...
  }: let
    hermes = inputs.hermes-agent.packages.${system};
    hermesWithDesktopCommand = pkgs.symlinkJoin {
      name = "hermes-agent-with-desktop-command";
      paths = [hermes.default];
      postBuild = ''
        rm -f "$out/bin/hermes"
        cat > "$out/bin/hermes" <<'EOF'
#!${pkgs.runtimeShell}
if [ "$#" -gt 0 ] && { [ "$1" = "desktop" ] || [ "$1" = "gui" ]; }; then
  shift
  exec ${lib.getExe hermes.desktop} "$@"
fi
exec ${lib.getExe hermes.default} "$@"
EOF
        chmod +x "$out/bin/hermes"
      '';
    };
  in {
    environment.systemPackages = [
      hermesWithDesktopCommand
      hermes.desktop
    ];

    environment.variables.HERMES_DESKTOP_REMOTE_URL = "https://agent.spitz-pickerel.ts.net";
  };
in {
  flake.modules.nixos.desktopHermes = module;
}
