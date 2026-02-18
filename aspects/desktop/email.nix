{...}: {
  programs.thunderbird = {
    enable = true;
  };

  # Thunderbird email configuration
  accounts.email.accounts = {
    evanaze = {
      name = "Evanaze Gmail";
      address = "evanaze@gmail.com";
      flavor = "gmail.com";
      primary = true;
      realName = "Evan Azevedo";
      thunderbird.enable = true;
    };
  };
}
