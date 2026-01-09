{pkgs, ...}: {
  users = {
    users = {
      root = {
        initialHashedPassword = "";
      };
      evanaze = {
        group = "nixos";
        initialHashedPassword = "";
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "networkmanager"
          "video"
        ];
        shell = pkgs.zsh;
      };
    };

    groups = {
      nixos = {};
    };
  };

  # Don't require sudo/root to `reboot` or `poweroff`.
  security.polkit.enable = true;

  # Allow passwordless sudo from nixos user
  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  # Automatically log in at the virtual consoles.
  services.getty.autologinUser = "evanaze";

  # We run sshd by default. Login is only possible after adding a
  # password via "passwd" or by adding a ssh key to ~/.ssh/authorized_keys.
  # The latter one is particular useful if keys are manually added to
  # installation device for head-less systems i.e. arm boards by manually
  # mounting the storage in a different system.
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };

  # allow nix-copy to live system
  nix.settings.trusted-users = ["evanaze"];
}
