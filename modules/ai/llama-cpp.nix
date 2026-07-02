let
  module = {
    lib,
    pkgs,
    config,
    inputs,
    ...
  }: {
    fileSystems."/mnt/jupiter-llama-models" = {
      device = "192.168.50.79:/mnt/eye/llama-models";
      fsType = "nfs";
      options = [
        "_netdev"
        "ro"
        "nfsvers=4.2"
        "noauto"
        "nofail"
        "x-systemd.automount"
        "x-systemd.idle-timeout=600"
        "noatime"
        "hard"
      ];
    };

    services.llama-cpp = {
      enable = true;
      modelsDir = "/mnt/jupiter-llama-models";
      modelsPreset = {
        "Qwen3.6 28B-A3B REAP" = {
          model = "Qwen3.6-28B-REAP20-A3B-Q4_K_M.gguf";
          alias = "qwen3.6-reap";
          context = 64000;
        };
      };
    };
  };
in {
  flake.modules.nixos = {
    aiLlamaCpp = module;
    aiServer = module;
  };
}
