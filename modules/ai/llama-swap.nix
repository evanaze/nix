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
  source-model-dir = "/mnt/jupiter-llama-models";
  staging-root = "/var/tmp/llama-cpp";
  ctx-size = 64000;
  stage-helper = ''
    set -euo pipefail

    STAGE_ROOT="${staging-root}"
    STAGE_DIR=""

    cleanup() {
      if [ -n "$STAGE_DIR" ] && [ -d "$STAGE_DIR" ]; then
        /run/current-system/sw/bin/rm -rf -- "$STAGE_DIR"
      fi
    }
    trap cleanup EXIT INT TERM HUP QUIT

    /run/current-system/sw/bin/mkdir -p "$STAGE_ROOT"
    STAGE_DIR="$(/run/current-system/sw/bin/mktemp -d "$STAGE_ROOT"/llama-swap-launch.XXXXXXXX)"

    stage_model() {
      local src_file="$1"
      local staged_file="$2"
      local tmp_file
      local src_size=0
      local staged_size=0

      if [ ! -r "$src_file" ]; then
        echo "llama-swap: source model file not readable: $src_file" >&2
        exit 1
      fi

      src_size=$(/run/current-system/sw/bin/stat -c '%s' "$src_file")
      if [ "$src_size" -le 0 ]; then
        echo "llama-swap: source model file is empty: $src_file" >&2
        exit 1
      fi

      tmp_file="$STAGE_DIR/.tmp.$$.$RANDOM.$(/run/current-system/sw/bin/basename "$src_file")"
      /run/current-system/sw/bin/cp -- "$src_file" "$tmp_file"
      staged_size=$(/run/current-system/sw/bin/stat -c '%s' "$tmp_file")
      if [ "$staged_size" -le 0 ] || [ "$staged_size" -ne "$src_size" ]; then
        echo "llama-swap: staged model is invalid or incomplete: $src_file" >&2
        exit 1
      fi

      /run/current-system/sw/bin/mv -- "$tmp_file" "$staged_file"
    }
  '';
in {
  # Earth uses a read-only NFS mount from Jupiter for model staging source.
  fileSystems."/mnt/jupiter-llama-models" = {
    device = "192.168.50.80:/mnt/eye/llama-models";
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

  services.llama-swap = {
    enable = true;
    port = 8724;
    settings = {
      models = {
        "qwen3.6-35b-a3b" = {
          cmd = ''
            ${stage-helper}
            stage_model "${source-model-dir}/Qwen3.6-35B-A3B-UD-Q4_K_XL.gguf" "$STAGE_DIR/Qwen3.6-35B-A3B-UD-Q4_K_XL.gguf"
            ${llama-server} \
                          -m "$STAGE_DIR/Qwen3.6-35B-A3B-UD-Q4_K_XL.gguf" \
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
            healthCheckTimeout = 600;
          };
        "gemma-4-12b-q4" = {
          cmd = ''
            ${stage-helper}
            stage_model "${source-model-dir}/gemma-4-12B-it-qat-UD-Q4_K_XL.gguf" "$STAGE_DIR/gemma-4-12B-it-qat-UD-Q4_K_XL.gguf"
            stage_model "${source-model-dir}/gemma-4-12B-it-assistant-Q8_0.gguf" "$STAGE_DIR/gemma-4-12B-it-assistant-Q8_0.gguf"
            ${llama-server} \
                          -m "$STAGE_DIR/gemma-4-12B-it-qat-UD-Q4_K_XL.gguf" \
                          --spec-draft-model "$STAGE_DIR/gemma-4-12B-it-assistant-Q8_0.gguf" \
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
            healthCheckTimeout = 600;
          };
        };
      };
  };

  systemd.services.llama-swap.serviceConfig = {
    MemoryDenyWriteExecute = lib.mkForce false;
    ProtectSystem = lib.mkForce "full";
    PrivateTmp = lib.mkForce false;
    PrivateMounts = lib.mkForce false;
    StateDirectory = "llama-cpp";
  };

  systemd.tmpfiles.rules = [
    "d ${staging-root} 1777 root root -"
  ];

  systemd.services.llama-swap-stale-cleanup = {
    description = "Prune stale llama-swap staging directories under /var/tmp/llama-cpp";
    after = ["local-fs.target"];
    before = ["llama-swap.service"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
    script = ''
      set -euo pipefail

      STAGE_ROOT="${staging-root}"
      /run/current-system/sw/bin/mkdir -p "$STAGE_ROOT"

      for d in "$STAGE_ROOT"/llama-swap-launch.*; do
        if [ -d "$d" ]; then
          /run/current-system/sw/bin/rm -rf -- "$d"
        fi
      done
    '';
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
      Restart = "on-failure";
      RestartSec = "10s";
    };
    script = ''
      ${lib.getExe pkgs.tailscale} serve clear svc:llm || true
      ${lib.getExe pkgs.tailscale} serve --service=svc:llm --https=443 ${toString config.services.llama-swap.port}
    '';
  };
};
in {
  flake.modules.nixos = {
    aiLlamaSwap = module;
    aiServer = module;
  };
}
