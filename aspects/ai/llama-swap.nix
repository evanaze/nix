{
  lib,
  pkgs,
  config,
  ...
}: let
  llama-cpp-cuda = pkgs.llama-cpp.override {
    cudaSupport = true;
    rocmSupport = false;
    metalSupport = false;
  };
  llama-server = lib.getExe' llama-cpp-cuda "llama-server";
in {
  services.llama-swap = {
    enable = true;
    port = 8724;
    settings = {
      models = {
        "qwen3.6-35b-a3b" = {
          cmd = ''
            ${llama-server} \
                          -m /var/lib/llama-cpp/models/Qwen3.6-35B-A3B-UD-Q3_K_S.gguf \
                          --temp 1.0 \
                          --top-p 0.95 \
                          --top-k 20 \
                          --min-p 0.00 \
                          --presence-penalty 1.5 \
                          --repetition-penalty 1.0 \
                          -ngl 24 \
                          -c 32768 \
                          -b 256 \
                          -t 6 \
                          -fa on \
                          --port ''${PORT}'';
          healthCheckTimeout = 180;
        };
        "qwen3.6-27b" = {
          cmd = ''
            ${llama-server} \
                          -m /var/lib/llama-cpp/models/Qwen3.6-27B-Q4_K_M.gguf \
                          --temp 1.0 \
                          --top-p 0.95 \
                          --min-p 0.00 \
                          --top-k 20 \
                          --presence-penalty 1.5 \
                          -ngl 22 \
                          -c 4096 \
                          -b 256 \
                          -t 6 \
                          -fa on \
                          --port ''${PORT}'';
          healthCheckTimeout = 300;
        };
      };
    };
  };

  systemd.services.llama-swap.serviceConfig = {
    MemoryDenyWriteExecute = lib.mkForce false;
    ProtectSystem = lib.mkForce "full";
    StateDirectory = "llama-cpp";
  };

  systemd.services.llm-tsserve = {
    after = [
      "tailscaled-autoconnect.service"
      "llama-swap.service"
    ];
    wants = [
      "tailscaled-autoconnect.service"
      "llama-swap.service"
    ];
    wantedBy = ["multi-user.target"];
    description = "Using Tailscale Serve to publish Llama Swap";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = "${lib.getExe pkgs.tailscale} serve --service=svc:llm --https=${toString config.services.llama-swap.port} ${toString config.services.llama-swap.port}";
  };
}
