{username, ...}: {
  home-manager.users.${username} = {
    slippi-launcher = {
      enable = true;
      isoPath = "/home/evanaze/Downloads/melee.iso";
      launchMeleeOnPlay = false;
    };
  };
}

