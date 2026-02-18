{username, ...}: {
  home-manager.users.${username} = {pkgs, ...}: {
    programs.thunderbird = {
      enable = true;
      profiles."Default".isDefault = true;
    };

    # Thunderbird email configuration
    accounts.email.accounts = {
      evanaze = {
        # name = "Evanaze Gmail";
        address = "evanaze@gmail.com";
        flavor = "gmail.com";
        primary = true;
        realName = "Evan Azevedo";
        thunderbird.enable = true;
      };
    };
  };
}
