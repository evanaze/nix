{pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix
    # ./ups.nix
    ../shared
    ../shared/pc
  ];

  networking.hostName = "jupiter";

  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #  wget
  ];

  # Keep awake
  services.displayManager.gdm.autoSuspend = false;

  system.stateVersion = "25.11";
}
