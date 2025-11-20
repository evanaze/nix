{...}: {
  services.seafile = {
    enable = true;

    adminEmail = "evanaze@gmail.com";
    initialAdminPassword = "admin";

    ccnetSettings.General.SERVICE_URL = "https://seafile.example.com";

    seafileSettings = {
      quota.default = "50"; # Amount of GB allotted to users
      history.keep_days = "14"; # Remove deleted files after 14 days
      fileserver = {
        host = "unix:/run/seafile/server.sock";
        web_token_expire_time = 18000; # Expire the token in 5h to allow longer uploads
      };
    };

    gc = {
      enable = true;
      dates = ["Sun 03:00:00"];
    };
  };
}
