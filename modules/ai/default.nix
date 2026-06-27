{
  flake.modules.nixos.aiServer = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      llmfit
    ];
  };
}
