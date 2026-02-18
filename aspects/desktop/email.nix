{username, ...}: {
  home-manager.users.${username} = {pkgs, ...}: {
    programs.thunderbird = {
      enable = true;
      profiles."Default".isDefault = true;
    };

    accounts.email.accounts = {
      "evanaze@gmail.com" = {
        address = "evanaze@gmail.com";
        flavor = "gmail.com";
        primary = true;
        realName = "Evan Azevedo";
        thunderbird.enable = true;
      };
      "evanazzvd@gmail.com" = {
        address = "evanazzvd@gmail.com";
        flavor = "gmail.com";
        realName = "Evan Azevedo";
        thunderbird.enable = true;
      };
      "evan@azevedo.com" = {
        address = "evan@azevedo.com";
        realName = "Evan Azevedo";
        thunderbird.enable = true;
        imap = {
          host = "mail.hover.com";
          tls.useStartTls = true;
        };
        smtp = {
          host = "mail.hover.com";
          tls.useStartTls = true;
        };
      };
      "evan@stackmagic.io" = {
        address = "evan@stackmagic.io";
        realName = "Evan Azevedo";
        thunderbird.enable = true;
        imap = {
          host = "imap.hostinger.com";
          tls.useStartTls = true;
        };
        smtp = {
          host = "smtp.hostinger.com";
          tls.useStartTls = true;
        };
      };
    };
  };
}
