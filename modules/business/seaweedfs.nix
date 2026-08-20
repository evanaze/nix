let
  module = {
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
      after = [
        "network.target"
        "zfs-mount.service"
        "sops-secrets.target"
      ];
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
          '{
            identities: [
              {
                name: "ducklake",
                credentials: [{accessKey: $key, secretKey: $secret}],
                actions: ["Read", "Write", "Admin"]
              }
            ]
          }' > ${s3ConfigFile}
      '';
      script = ''
        ${lib.getExe pkgs.seaweedfs} server \
          -dir=${dataDir} \
          -s3 \
          -s3.port=${toString seaweedfsS3Port} \
          -s3.config=${s3ConfigFile}
      '';
    };

    services.tailscale.serve.services.swfs.endpoints."tcp:443" = "https://127.0.0.1:${toString seaweedfsS3Port}";
  };
in {
  flake.modules.nixos = {
    businessSeaweedfs = module;
    business = module;
  };
}
