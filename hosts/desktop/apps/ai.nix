{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    ollama-cuda
  ];

  services.open-webui = {
    enable = true;
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
    loadModels = ["deepseek-r1:14b"];
  };

  systemd.services.tailscale-serve-open-webui = {
    after = ["tailscaled.service"];
    wants = ["tailscaled.service"];
    wantedBy = ["multi-user.target"];
    description = "Using Tailscale Serve to publish my AI Chatbot";
    serviceConfig = {
      Type = "exec";
    };
    script = ''
      ${pkgs.tailscale}/bin/tailscale serve 8080
    '';
  };
}
