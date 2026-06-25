let
  module = {
  pkgs,
  username,
  ...
}: {
  nixpkgs.overlays = [
    (final: prev: {
      restic = prev.restic.overrideAttrs (old: {
        version = "0.18.1";
        src = prev.fetchFromGitHub {
          owner = "restic";
          repo = "restic";
          rev = "v0.18.1";
          sha256 = "0gxhknn022bwg2s8hababqg3vjkzflq59vr67y7r1c8fjnlsgf4l";
        };
        goModules = old.goModules // {
          outputHash = "sha256-4GVhG1sjFiuKyDUAgmSmFww5bDKIoCjejkkoSqkvU4E=";
        };
      });
    })
  ];
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

  services.restic.backups.files = {
    initialize = true;
    passwordFile = "/run/secrets/restic-password";
    repository = "/mnt/drive/backup";
    paths = [
      "/var/lib/immich"
      "/var/lib/tailscale"
      "/var/lib/postgresql-dump.sql"
      "/mnt/eye"
    ];
    exclude = [
      "/mnt/eye/media"
    ];
    backupPrepareCommand = ''
      ${pkgs.postgresql}/bin/pg_dumpall -U postgres -f /var/lib/postgresql-dump.sql
    '';
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

  services.restic.backups.media = {
    initialize = true;
    passwordFile = "/run/secrets/restic-password";
    repository = "/mnt/drive/backup";
    paths = [
      "/mnt/eye/media"
    ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };
    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 5"
      "--keep-monthly 12"
      "--keep-yearly 75"
    ];
  };

  services.prometheus.exporters.restic = {
    enable = true;
    repository = "/mnt/drive/backup";
    passwordFile = "/run/secrets/restic-password";
    user = "root";
  };

  sops.secrets.restic-password = {};
};
in {
  flake.modules.nixos = {
    backupRestic = module;
    backup = module;
  };
}
