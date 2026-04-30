{
  pkgs,
  config,
  lib,
  ...
}: let
  llama-cpp-cuda = pkgs.llama-cpp.override {
    cudaSupport = true;
    rocmSupport = false;
    metalSupport = false;
  };
  llama-server = lib.getExe' llama-cpp-cuda "llama-server";
in {
  environment.systemPackages = with pkgs; [
    llmfit
    lmstudio
    pi-coding-agent
    # python312Packages.huggingface-hub
    # vllm
  ];

  # services.llama-cpp = {
  #   enable = true;
  #   port = 8723;
  #   package = llama-cpp-cuda;
  # };

  services.llama-swap = {
    enable = true;
    port = 8724;
    settings = {
      models = {
        "qwen3.6-35b-a3b" = {
          cmd = "${llama-server} --port \${PORT} -m /var/lib/llama-cpp/models/Qwen3.6-35B-A3B-UD-Q3_K_S.gguf -ngl 40 -c 8192 -b 512 -t 8 -fa on";
          healthCheckTimeout = 180;
        };
      };
    };
  };

  systemd.services.llama-swap.serviceConfig = {
    MemoryDenyWriteExecute = lib.mkForce false;
    ProtectSystem = lib.mkForce "full";
    StateDirectory = "llama-cpp";
  };
}
