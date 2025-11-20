{pkgs, ...}: {
  home.packages = with pkgs; [
    thunderbird
  ];

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
