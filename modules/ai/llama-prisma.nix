let
  module = {
    lib,
    pkgs,
    config,
    ...
  }: let
    inherit (lib) mkIf mkEnableOption mkOption types;
  in {
    options.services.llama-prisma = {
      enable = mkEnableOption "PrismML-Eng llama.cpp fork for Bonsai ternary models";

      package = mkOption {
        type = types.package;
        default = pkgs.callPackage ../pkgs/llama-prisma {
          cudaSupport = config.services.llama-prisma.cudaSupport;
        };
        description = "The llama-prisma package to use";
      };

      cudaSupport = mkOption {
        type = types.bool;
        default = false;
        description = "Enable CUDA support in the PrismML llama.cpp build";
      };

      server = {
        enable = mkEnableOption "llama-prisma server systemd service";

        host = mkOption {
          type = types.str;
          default = "127.0.0.1";
          description = "Host address to bind the server";
        };

        port = mkOption {
          type = types.port;
          default = 8080;
          description = "Port to serve the API on";
        };

        model = mkOption {
          type = types.str;
          default = "";
          description = "Path to the GGUF model file to load";
        };

        ngl = mkOption {
          type = types.int;
          default = 99;
          description = "Number of layers to offload to GPU (-ngl)";
        };

        extraArgs = mkOption {
          type = types.listOf types.str;
          default = [];
          description = "Extra arguments passed to llama-server";
        };
      };
    };

    config = mkIf config.services.llama-prisma.enable {
      environment.systemPackages = [
        config.services.llama-prisma.package
      ];

      environment.variables = {
        LLAMA_PRISMA_BIN = "${config.services.llama-prisma.package}/bin";
      };

      systemd.services.llama-prisma-server = mkIf config.services.llama-prisma.server.enable {
        description = "PrismML llama.cpp server for Bonsai ternary models";
        after = ["network.target"];
        wants = ["network.target"];
        wantedBy = ["multi-user.target"];

        environment = {
          GGML_CUDA_ENABLE_UNIFIED_MEMORY = "0";
        };

        serviceConfig = {
          Type = "simple";
          ExecStart = let
            serverBin = "${config.services.llama-prisma.package}/bin/llama-server";
            args = [
              "--host" config.services.llama-prisma.server.host
              "--port" (toString config.services.llama-prisma.server.port)
              "-ngl" (toString config.services.llama-prisma.server.ngl)
            ]
            ++ lib.optionals (config.services.llama-prisma.server.model != "") [
              "-m" config.services.llama-prisma.server.model
            ]
            ++ config.services.llama-prisma.server.extraArgs;
          in "${serverBin} ${lib.escapeShellArgs args}";
          Restart = "on-failure";
          RestartSec = "10s";
          # The PrismML fork uses CUDA-accelerated low-bit kernels; keep the GPU accessible
          PrivateDevices = false;
          ProtectSystem = "full";
          PrivateTmp = true;
          MemoryDenyWriteExecute = false;
        };
      };
    };
  };
in {
  flake.modules.nixos = {
    aiLlamaPrisma = module;
  };
}