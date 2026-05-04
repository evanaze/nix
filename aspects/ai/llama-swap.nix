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
          cmd = "${llama-server} --port \${PORT} -m /var/lib/llama-cpp/models/Qwen3.6-35B-A3B-UD-Q3_K_S.gguf -ngl 30 -c 8192 -b 512 -t 8 -fa on";
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
