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

      log_msg() {
        /run/current-system/sw/bin/logger -t llama-swap-launch "$*" || true
        echo "$*"
      }

      cleanup() {
        if [ -n "$STAGE_DIR" ] && [ -d "$STAGE_DIR" ]; then
          /run/current-system/sw/bin/rm -rf -- "$STAGE_DIR"
        fi
      }
      trap cleanup EXIT INT TERM HUP QUIT

      /run/current-system/sw/bin/mkdir -p "$STAGE_ROOT"
      STAGE_DIR="$(/run/current-system/sw/bin/mktemp -d "$STAGE_ROOT"/llama-swap-launch.XXXXXXXX)"
      log_msg "[llama-swap] prepared staging directory $STAGE_DIR"

      run_llama_server() {
        local port="$1"
        shift

        if [ -z "$port" ]; then
          log_msg "llama-swap: missing PORT for launch"
          exit 1
        fi

        local log_file="$STAGE_DIR/.llama-server.$port.log"
        log_msg "[llama-swap] launching on $(/run/current-system/sw/bin/date '+%Y-%m-%dT%H:%M:%S%:z')"
        log_msg "[llama-swap] stage=$STAGE_DIR port=$port"
        command=""
        for arg in "$@"; do
          command="$command $(printf '%q' "$arg")"
        done
        log_msg "[llama-swap] command:$command"

        if ! "$@" >"$log_file" 2>&1; then
          local status=$?
          log_msg "[llama-swap] upstream command exited with status $status"
          /run/current-system/sw/bin/tail -n 200 "$log_file" >&2 || true
          return "$status"
        fi
      }
    '';

    mk-launch-script = name: script-body:
      pkgs.writeShellScript "llama-swap-${name}" ''
        ${stage-helper}

        PORT="''${1:-}"

        ${script-body}
      '';

    launchScriptQwen = mk-launch-script "qwen3.6-35b-a3b" ''
      run_llama_server "$PORT" \
        "${llama-server}" \
        -m "${source-model-dir}/Qwen3.6-35B-A3B-UD-Q4_K_XL.gguf" \
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
        --no-mmap \
        --parallel 1 --prio 2 --no-warmup \
        --spec-type draft-mtp --spec-draft-n-max 2 \
        --jinja \
        --chat-template-kwargs '{"preserve_thinking": true}' \
        --port "$PORT"
    '';

    launchScriptGemma = mk-launch-script "gemma-4-12b-q4" ''
      run_llama_server "$PORT" \
        "${llama-server}" \
        -m "${source-model-dir}/gemma-4-12B-it-qat-UD-Q4_K_XL.gguf" \
        --spec-draft-model "${source-model-dir}/gemma-4-12B-it-assistant-Q8_0.gguf" \
        --spec-type draft-mtp \
        --spec-draft-n-max 3 \
        --flash-attn on \
        --fit on --fit-target 1536 --fit-ctx ${toString ctx-size} \
        --parallel 1 \
        --no-mmap \
        --ctx-size ${toString ctx-size} \
        --temp 1.0 \
        --top-p 0.95 \
        --top-k 64 \
        --threads 10 --threads-batch 12 \
        --batch-size 512 --ubatch-size 256 \
        --mlock \
        --jinja \
        --chat-template-kwargs '{"preserve_thinking": true}' \
        --port "$PORT"
    '';
  in {
    environment.systemPackages = with pkgs; [
      tmux
    ];
    # Earth uses a read-only NFS mount from Jupiter as the llama.cpp model source.
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
            cmd = "${launchScriptQwen} ${"$"}{PORT}";
            healthCheckTimeout = 600;
          };
          "gemma-4-12b-q4" = {
            cmd = "${launchScriptGemma} ${"$"}{PORT}";
            healthCheckTimeout = 600;
          };
        };
      };
    };

    systemd.services.llama-swap.serviceConfig = {
      MemoryDenyWriteExecute = lib.mkForce false;
      ProtectSystem = lib.mkForce "full";
      # The model path is a systemd automount; keep the service in the host mount namespace.
      PrivateTmp = lib.mkForce false;
      PrivateMounts = lib.mkForce false;
      StateDirectory = "llama-cpp";
    };

    systemd.tmpfiles.rules = [
      "d ${staging-root} 1777 root root -"
    ];

    systemd.services.llama-swap-stale-cleanup = {
      description = "Prune stale llama-swap staging directories under ${staging-root}";
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
