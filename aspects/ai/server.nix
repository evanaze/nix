{pkgs, ...}: {
  imports = [
    ./llama-swap.nix
  ];

  environment.systemPackages = with pkgs; [
    llmfit
  ];
}
