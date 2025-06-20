{
  pkgs,
  lib,
  ...
}: {
  environment.systemPackages = with pkgs; [
    ollama-cuda
  ];

  services.open-webui = {
    enable = true;
    port = 8080;
    environment = {
      OLLAMA_API_BASE_URL = "http://127.0.0.1:11434";
      WEBUI_AUTH = "False";
    };
  };

  services.ollama = {
    enable = true;
    port = 11434;
    package = pkgs.ollama-cuda;
    acceleration = "cuda";
    loadModels = ["qwen2.5:14b" "qwen2.5-coder:14b"];
  };

  systemd.services.tsserve-open-webui = {
    after = ["tailscaled.service" "open-webui.service"];
    wants = ["tailscaled.service" "open-webui.service"];
    wantedBy = ["multi-user.target"];
    description = "Using Tailscale Serve to publish my AI Chatbot";
    serviceConfig = {
      Type = "exec";
    };
    script = "${lib.getExe pkgs.tailscale} serve 8080";
  };
}
