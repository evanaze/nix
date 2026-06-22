let
  module = {
    inputs,
    system,
    ...
  }: let
    hermes = inputs.hermes-agent.packages.${system};
  in {
    environment.systemPackages = [
      hermes.default
      hermes.desktop
    ];

    environment.variables.HERMES_DESKTOP_REMOTE_URL = "http://jupiter.spitz-pickerel.ts.net:9119";
  };
in {
  flake.modules.nixos.desktopHermes = module;
}
