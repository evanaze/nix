{
  pkgs,
  username,
  ...
}: {
  environment.systemPackages = with pkgs; [
    restic
  ];

  fileSystems."/mnt/drive" = {
    device = "/dev/disk/by-uuid/6950-3024";
    fsType = "exfat";
    options = [
      "nofail"
      "x-systemd.automount"
    ];
  };

  services.restic.backups.harddrive = {
    initialize = true;
    passwordFile = "/run/secrets/restic-password";
    repository = "/mnt/drive/backup";
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
    repository = "/mnt/drive/backup";
    passwordFile = "/run/secrets/restic-password";
    user = "root";
  };
}
