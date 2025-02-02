{username, ...}: {
  home-manager.users.${username} = {
    slippi-launcher = {
      enable = true;
      isoPath = "~/Downloads/melee.iso";
      launchMeleeOnPlay = false;
    };
  };
}

