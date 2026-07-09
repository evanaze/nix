let
  module = {username, ...}: {
    home-manager.users.${username}.programs.pi-coding-agent.settings.packages = [
      "npm:@cortexkit/aft"
    ];
  };
in {
  flake.modules.nixos = {
    developmentPiAgent = module;
    development = module;
  };
}
