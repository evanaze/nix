{pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix
    # ./ups.nix
    ../shared
    ../shared/pc
    ../shared/server.nix
    # ./tailscale-webui.nix
  ];

  networking.hostName = "jupiter";

  # Keep awake
  services.displayManager.gdm.autoSuspend = false;

  system.stateVersion = "25.11";
}
