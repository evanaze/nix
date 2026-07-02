let
  module = {
    lib,
    pkgs,
    config,
    inputs,
    ...
  }: {
    services.llama-cpp = {
      enable = true;
      settings = {
        port = 8724;
        models-preset = '''';
      };
    };
  };
in {
  flake.modules.nixos = {
    aiLlamaCpp = module;
  };
}
