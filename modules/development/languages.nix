let
  module = {
    pkgs,
    username,
    ...
  }: {
    home-manager.users.${username} = {
      home.packages = with pkgs; [
        cargo
        go
        hugo
        lua
        luarocks
        python3
      ];
    };
  };
in {
  flake.modules.nixos = {
    developmentLanguages = module;
    development = module;
  };
}
