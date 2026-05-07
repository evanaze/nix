{
  pkgs,
  username,
  inputs,
  ...
}: let
  hermes-agent = inputs.hermes-agent.packages.${pkgs.stdenv.system}.default;
  hermes-tui = hermes-agent.hermesTui;
in {
  home-manager.users.${username} = {
    home.packages = [
      hermes-agent
      hermes-tui
    ];
  };
}