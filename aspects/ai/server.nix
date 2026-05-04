{pkgs, ...}: {
  imports = [
    ./llama-swap.nix
    ./open-webui.nix
  ];

  environment.systemPackages = with pkgs; [
    llmfit
  ];
}
