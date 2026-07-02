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
    systemd-inhibit = lib.getExe' pkgs.systemd "systemd-inhibit";
    source-model-dir = "/mnt/jupiter-llama-models";
    staging-root = "/var/tmp/llama-cpp";

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

        if ! "${systemd-inhibit}" \
          --what=sleep \
          --mode=block \
          --why="llama-swap model on port $port is loaded" \
          "$@" >"$log_file" 2>&1; then
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
        --ctx-size 32768 \
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

    launchScriptQwenReap = mk-launch-script "qwen3.6-reap" ''
      run_llama_server "$PORT" \
        "${llama-server}" \
        -m "${source-model-dir}/Qwen3.6-28B-REAP20-A3B-Q4_K_M.gguf" \
        --ctx-size 8192 \
        -b 2048 \
        -ub 1024 \
        --no-mmap \
        --mlock \
        -t 3 \
        --temp 0.7 \
        --top-p 0.95 \
        --top-k 20 \
        --min-p 0.0 \
        --presence-penalty 0.0 \
        --repeat-penalty 1.0 \
        --jinja \
        --cache-reuse 256 \
        --n-cpu-moe 17 \
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
        --fit on --fit-target 1536 --fit-ctx 128000 \
        --parallel 1 \
        --no-mmap \
        --ctx-size 128000 \
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

    launchScriptOrnith = mk-launch-script "ornith-1.0-9b-q4" ''
      run_llama_server "$PORT" \
        "${llama-server}" \
        -m "${source-model-dir}/ornith-1.0-9b-Q4_K_M.gguf" \
        --reasoning-format deepseek \
        --flash-attn on \
        --fit on --fit-target 1536 --fit-ctx 128000 \
        --parallel 1 \
        --no-mmap \
        --ctx-size 128000 \
        --temp 0.6 \
        --top-p 0.95 \
        --top-k 20 \
        --threads 10 --threads-batch 12 \
        --batch-size 512 --ubatch-size 256 \
        --mlock \
        --jinja \
        --port "$PORT"
    '';

    launchScriptMiniCPM = mk-launch-script "minicpm-v-4.6" ''
      run_llama_server "$PORT" \
        "${llama-server}" \
        -m "${source-model-dir}/MiniCPM-V-4_6-F16.gguf" \
        --mmproj "${source-model-dir}/mmproj-MiniCPM-V-4_6-F16.gguf" \
        -c 8192 --temp 0.7 --top-p 0.8 --top-k 100 --repeat-penalty 1.05 \
        --reasoning off \
        --port "$PORT"
    '';
  in {
    environment.systemPackages = with pkgs; [
      lact
    ];

    services.llama-swap = {
      enable = true;
      port = 8724;
      settings = {
        models = {
          "qwen3.6-35b-a3b" = {
            cmd = "${launchScriptQwen} ${"$"}{PORT}";
            healthCheckTimeout = 600;
          };
          "qwen3.6-reap" = {
            cmd = "${launchScriptQwenReap} ${"$"}{PORT}";
            healthCheckTimeout = 600;
          };
          "gemma-4-12b-q4" = {
            cmd = "${launchScriptGemma} ${"$"}{PORT}";
            healthCheckTimeout = 600;
          };
          "ornith-1.0-9b-q4" = {
            cmd = "${launchScriptOrnith} ${"$"}{PORT}";
            healthCheckTimeout = 600;
          };
          "minicpm-v-4.6" = {
            cmd = "${launchScriptMiniCPM} ${"$"}{PORT}";
            healthCheckTimeout = 600;
          };
        };
      };
    };

    security.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (
          action.id === "org.freedesktop.login1.inhibit-block-sleep" &&
          subject.system_unit === "llama-swap.service"
        ) {
          return polkit.Result.YES;
        }
      });
    '';

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
