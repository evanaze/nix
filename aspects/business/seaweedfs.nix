{
  config,
  lib,
  pkgs,
  ...
}: let
  seaweedfsS3Port = 8333;
  dataDir = "/storage/data/seaweedfs";
  s3ConfigFile = "/run/seaweedfs-s3.json";
in {
  sops.secrets."seaweedfs/s3-access-key" = {};
  sops.secrets."seaweedfs/s3-secret-key" = {};

  systemd.tmpfiles.rules = [
    "d ${dataDir} 0750 root root -"
    "d /run/seaweedfs 0755 root root -"
  ];

  systemd.services.seaweedfs = {
    after = ["network.target" "zfs-mount.service" "sops-secrets.target"];
    requires = ["zfs-mount.service"];
    wantedBy = ["multi-user.target"];
    description = "SeaweedFS - S3-compatible object store for DuckLake";
    serviceConfig = {
      Type = "simple";
      User = "root";
      Restart = "on-failure";
      RestartSec = "5s";
    };
    preStart = ''
      ${lib.getExe pkgs.jq} -n \
        --arg key "$(cat ${config.sops.secrets."seaweedfs/s3-access-key".path})" \
        --arg secret "$(cat ${config.sops.secrets."seaweedfs/s3-secret-key".path})" \
        '[
          {
            name: "ducklake",
            actions: ["Read", "Write", "Admin"],
            credentials: [{accessKey: $key, secretKey: $secret}]
          }
        ]' > ${s3ConfigFile}
    '';
    script = ''
      ${lib.getExe pkgs.seaweedfs} server \
        -dir=${dataDir} \
        -s3 \
        -s3.port=${toString seaweedfsS3Port} \
        -s3.config=${s3ConfigFile}
    '';
  };

  systemd.services.seaweedfs-tsserve = {
    after = [
      "tailscaled-autoconnect.service"
      "seaweedfs.service"
    ];
    wants = [
      "tailscaled-autoconnect.service"
      "seaweedfs.service"
    ];
    wantedBy = ["multi-user.target"];
    description = "Publish SeaweedFS S3 API via Tailscale Serve";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = "${lib.getExe pkgs.tailscale} serve --service=svc:dwh --https=4445 ${toString seaweedfsS3Port}";
  };
}

