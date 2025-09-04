{
  inputs,
  username,
  ...
}: {
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  # Set your time zone.
  time.timeZone = "America/Denver";

  ## Garbage collector
  nix.gc = {
    automatic = true;
    dates = "Monday 01:00 UTC";
    options = "--delete-older-than 7d";
  };

  # Sops
  sops = {
    defaultSopsFile = ./secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyfile = "/home/${username}/.config/sops/age/keys.txt";
  };

  system = {
    # Auto upgrade
    autoUpgrade = {
      enable = true;
      allowReboot = true;
      # Daily 00:00
      dates = "daily UTC";
    };
  };

  services.tailscale.enable = true;
}
