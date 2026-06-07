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
                          -m /var/lib/llama-cpp/models/Qwen3.6-35B-A3B-UD-Q4_K_XL.gguf \
                          -ctx-size 131072 \
                          --n-predict 32768 \
                          --fit on --fit-target 1536 --fit-ctx 131072 \
                          --temp 0.6 --top-p 0.95 --top-k 20 \
                          --presence-penalty 0.0 --repeat-penalty 1.0 \
                          -ctk q8_0 -ctv q8_0 \
                          --flash-attn on \
                          --batch-size 1024 --ubatch-size 512 \
                          --threads 10 --threads-batch 12 \
                          --no-mmap --mlock \
                          --parallel 1 --prio 2 --no-warmup \
                          --spec-type draft-mtp --spec-draft-n-max 2 \
                          --jinja \
                          --chat-template-kwargs "{\"preserve_thinking\": true}"
                          --port ''${PORT}'';
          healthCheckTimeout = 180;
        };
        "gemma-4-12b-q4" = {
          cmd = ''
            ${llama-server} \
                          -m /var/lib/llama-cpp/models/gemma-4-12B-it-qat-UD-Q4_K_XL.gguf \
                          -model-draft /var/lib/llama-cpp/models/gemma-4-12B-it-assistant-Q8_0.gguf \
                          --spec-type draft-mtp \
                          --spec-draft-n-max 3 \
                          --flash-attn on \
                          --fit on --fit-target 1536 \
                          --parallel 1 \
                          --ctx-size 131072 \
                          --temp 1.0 \
                          --top-p 0.95 \
                          --top-k 64 \
                          --port ''${PORT}'';
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
