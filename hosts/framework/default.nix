{...}: {
  imports = [
    # Include the results of the hardware scan.
    ./fprint.nix

    <nixos-hardware/framework/13-inch/7040-amd>
    ./hardware-configuration.nix
    ../shared.nix
    ../nixos-shared.nix
    ../linux-dev-shared.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "fw"; # Define your hostname.

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Needed for easyeffects
  programs.dconf.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Enable bios updates
  services.fwupd.enable = true;
  hardware.framework.enableKmod = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # Install firefox.
  programs.firefox.enable = true;

  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "25.05"; # Did you read the comment?
}
