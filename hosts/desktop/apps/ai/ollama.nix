{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    ollama-cuda
  ];

  services.ollama = {
    enable = true;
    port = 11434;
    package = pkgs.ollama-cuda;
    acceleration = "cuda";
    loadModels = ["qwen2.5:14b" "qwen2.5-coder:14b" "devstral"];
  };
}
