{pkgs, ...}: {
  users = {
    mutableUsers = false;

    users = {
      root = {
        hashedPassword = "*";
      };
      evanaze = {
        group = "nixos";
        hashedPassword = "$y$j9T$0PUNfPgT4X7Dy10pAPMIw0$e29wtHpG0H0sM6Qp0j6tdo7zZLrxUQXcmZkxj9Gw0T1";
        isNormalUser = true;
        extraGroups = ["wheel"];
        shell = pkgs.zsh;
      };
    };

    groups = {
      nixos = {};
    };
  };
}
