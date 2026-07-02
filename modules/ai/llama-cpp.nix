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
      # modelsDir = "/mnt/jupiter-llama-models";
      settings = {
        models-preset = '''';
      };
    };
  };
in {
  flake.modules.nixos = {
    aiLlamaCpp = module;
    aiServer = module;
  };
}
