let
  module = {username, ...}: {
    home-manager.users.${username} = {
      home.file.".config/cortexkit/aft.jsonc" = {
        text = ''
          {
            "$schema": "https://raw.githubusercontent.com/cortexkit/aft/main/assets/aft.schema.json",
            "disabled_tools": ["read", "write", "edit", "bash"]
          }
        '';
      };
      programs.pi-coding-agent.settings.packages = [
        "npm:@cortexkit/aft-pi"
      ];
    };
  };
in {
  flake.modules.nixos = {
    developmentPiAgent = module;
    development = module;
  };
}
