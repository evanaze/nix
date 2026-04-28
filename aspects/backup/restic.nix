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
    passwordFile = "/run/secrets/restic-password";
    repository = "/backup/drive/backup";
    paths = [
      "/home/${username}/Documents"
      "/home/${username}/Downloads"
    ];
    pruneOpts = [
      "--keep-hourly 24"
      "--keep-daily 7"
      "--keep-weekly 5"
      "--keep-monthly 12"
      "--keep-yearly 75"
    ];
    timerConfig = {
      OnCalendar = "hourly";
      Persistent = true;
    };
  };

  services.prometheus.exporters.restic = {
    enable = true;
    repository = "/backup/drive/backup";
    passwordFile = "/run/secrets/restic-password";
    user = "root";
  };
}
