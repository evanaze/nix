{
  pkgs,
  username,
  ...
}: {
  environment.systemPackages = with pkgs; [
    restic
  ];

  services.restic.backups.harddrive = {
    initialize = true;
    repository = "/mnt/";
    paths = [
      "/home/${username}/Documents"
      "/home/${username}/Downloads"
    ];
    passwordFile = "/run/secrets/restic-password";
    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 5"
      "--keep-monthly 12"
      "--keep-yearly 75"
    ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };
  };
}
