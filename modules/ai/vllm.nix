let
  module = {
    config,
    lib,
    pkgs,
    inputs,
    system,
    ...
  }: let
    vllmSystem = assert pkgs.stdenv.hostPlatform.system == system; pkgs.stdenv.hostPlatform.system;
    vllmPkgs = import inputs.nixpkgs {
      system = vllmSystem;
      config = {
        cudaSupport = true;
        # Forced outPath probes show nixpkgs refuses python3.13-vllm-0.16.0;
        # permitting vllm-0.16.0 alone still fails, so keep only the Python derivation.
        permittedInsecurePackages = [
          "python3.13-vllm-0.16.0"
        ];
        allowUnfreePredicate = package: let
          license = package.meta.license or null;
          licenses =
            if builtins.isList license
            then license
            else [license];
        in
          builtins.any (item:
            builtins.elem (item.shortName or "") [
              "CUDA EULA"
              "cuDNN EULA"
              "cuSPARSELt EULA"
            ])
          licenses;
      };
    };
    vllmPackage = vllmPkgs.vllm;
    vllmBinary = "${vllmPackage}/bin/vllm";
  in {
    config = lib.mkIf (config.networking.hostName == "earth") {
      users.groups.vllm = {};
      users.users.vllm = {
        isSystemUser = true;
        group = "vllm";
        home = "/var/lib/vllm";
      };

      environment.systemPackages = [
        vllmPackage
      ];

      environment.variables.VLLM_BIN = vllmBinary;

      # vLLM intentionally shares llama-swap's port 8724 and has no wantedBy entry;
      # operators manually start exactly one backend when switching that local API slot.
      systemd.services.vllm = {
        description = "Local OpenAI-compatible vLLM server";
        after = ["network-online.target"];
        wants = ["network-online.target"];
        environment = {
          HF_HOME = "/var/cache/vllm/huggingface";
          VLLM_CACHE_ROOT = "/var/cache/vllm/vllm";
          XDG_CACHE_HOME = "/var/cache/vllm/xdg";
        };
        serviceConfig = {
          Type = "simple";
          User = "vllm";
          Group = "vllm";
          WorkingDirectory = "/var/lib/vllm";
          StateDirectory = "vllm";
          CacheDirectory = "vllm";
          ExecStart = "${vllmPackage}/bin/vllm serve Qwen/Qwen3-8B --host 127.0.0.1 --port 8724";
          Restart = "on-failure";
          RestartSec = "10s";
        };
      };
    };
  };
in {
  flake.modules.nixos = {
    aiVllm = module;
  };
}
