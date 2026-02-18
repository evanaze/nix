{username, ...}: {
  home-manager.users.${username} = {pkgs, ...}: {
    programs.thunderbird = {
      enable = true;
      profiles."Default".isDefault = true;
    };

    # Thunderbird email configuration
    accounts.email.accounts = {
      "evanaze@gmail.com" = {
        address = "evanaze@gmail.com";
        flavor = "gmail.com";
        primary = true;
        realName = "Evan Azevedo";
        thunderbird.enable = true;
        imap = {
          host = "imap.gmail.com";
          tls.useStartTls = true;
        };
        smtp = {
          host = "smtp.gmail.com";
          tls.useStartTls = true;
        };
      };
    };
  };
}
