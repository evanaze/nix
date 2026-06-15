let
  module = {
  lib,
  pkgs,
  config,
  inputs,
  ...
}: let
  llama-cpp = inputs.llama-cpp.packages.${pkgs.system}.cuda;
  llama-server = lib.getExe' llama-cpp "llama-server";
  model-dir = "/var/lib/llama-cpp/models";
  ctx-size = 64000;
in {
  services.llama-swap = {
    enable = true;
    port = 8724;
    settings = {
      models = {
        "qwen3.6-35b-a3b" = {
          cmd = ''
            ${llama-server} \
                          -m ${model-dir}/Qwen3.6-35B-A3B-UD-Q4_K_XL.gguf \
                          --ctx-size ${toString ctx-size} \
                          --n-predict 8192 \
                          --fit on --fit-target 1536 --fit-ctx 32768 \
                          --temp 0.6 --top-p 0.95 --top-k 20 \
                          --presence-penalty 0.0 --repeat-penalty 1.0 \
                          -ctk q8_0 -ctv q8_0 \
                          --flash-attn on \
                          --batch-size 512 --ubatch-size 256 \
                          --threads 10 --threads-batch 12 \
                          --mlock \
                          --parallel 1 --prio 2 --no-warmup \
                          --spec-type draft-mtp --spec-draft-n-max 2 \
                          --jinja \
                          --chat-template-kwargs "{\"preserve_thinking\": true}" \
                          --port ''${PORT}'';
          healthCheckTimeout = 180;
        };
        "gemma-4-12b-q4" = {
          cmd = ''
            ${llama-server} \
                          -m ${model-dir}/gemma-4-12B-it-qat-UD-Q4_K_XL.gguf \
                          --spec-draft-model ${model-dir}/gemma-4-12B-it-assistant-Q8_0.gguf \
                          --spec-type draft-mtp \
                          --spec-draft-n-max 3 \
                          --flash-attn on \
                          --fit on --fit-target 1536 --fit-ctx ${toString ctx-size} \
                          --parallel 1 \
                          --ctx-size ${toString ctx-size} \
                          --temp 1.0 \
                          --top-p 0.95 \
                          --top-k 64 \
                          --threads 10 --threads-batch 12 \
                          --batch-size 512 --ubatch-size 256 \
                          --mlock \
                          --jinja \
                          --chat-template-kwargs "{\"preserve_thinking\": true}" \
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
};
in {
  flake.modules.nixos = {
    aiLlamaSwap = module;
    aiServer = module;
  };
}
