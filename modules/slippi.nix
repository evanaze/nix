{username, ...}: {
  home-manager.users.${username} = {
    slippi-launcher = {
      enable = true;
      isoPath = "~/Documents/melee.iso";
      launchMeleeOnPlay = false;
    };
  };
}

