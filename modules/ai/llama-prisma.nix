let
  module = {
    lib,
    pkgs,
    config,
    ...
  }: let
    inherit (lib) mkIf;
  in {
    imports = [
      (pkgs.callPackage ../pkgs/llama-prisma/nixos-module.nix {})
    ];

    config = mkIf (config.networking.hostName == "earth") {
      services.llama-prisma = {
        enable = true;
        cudaSupport = true;
        server = {
          enable = true;
          model = "/mnt/jupiter-llama-models/Ternary-Bonsai-27B-dspark-bf16.gguf";
          port = 8083;
          ngl = 99;
          extraArgs = [
            "--flash-attn"
            "on"
            "--ctx-size"
            "128000"
            "-ctk"
            "q8_0"
            "-ctv"
            "q8_0"
            "--parallel"
            "1"
            "--batch-size"
            "512"
            "--ubatch-size"
            "256"
            "--threads"
            "10"
            "--threads-batch"
            "12"
            "--temp"
            "0.7"
            "--top-p"
            "0.95"
            "--top-k"
            "20"
            "--jinja"
            "--cache-reuse"
            "256"
          ];
        };
      };
    };
  };
in {
  flake.modules.nixos = {
    aiLlamaPrisma = module;
  };
}
