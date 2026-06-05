{
  config,
  pkgs,
  username,
  ...
}: {
  sops.secrets = {
    "seaweedfs/s3-access-key" = {
      owner = username;
      mode = "0400";
    };
    "seaweedfs/s3-secret-key" = {
      owner = username;
      mode = "0400";
    };
    "ducklake/db-password" = {
      owner = username;
      mode = "0400";
    };
  };

  environment.systemPackages = with pkgs; [duckdb];

  home-manager.users.${username} = {
    home.file.".local/bin/ducklake" = {
      executable = true;
      text = ''
        #!/run/current-system/sw/bin/bash
        set -euo pipefail

        S3_KEY="$(cat ${config.sops.secrets."seaweedfs/s3-access-key".path})"
        S3_SECRET="$(cat ${config.sops.secrets."seaweedfs/s3-secret-key".path})"
        DB_PASS="$(cat ${config.sops.secrets."ducklake/db-password".path})"

        INIT="$(mktemp)"
        trap 'rm -f "$INIT"' EXIT

        cat > "$INIT" << 'SQLEOF'
        LOAD httpfs;
        LOAD ui;
        LOAD postgres;
        SET s3_region = 'us-east-1';
        SET s3_endpoint = 'jupiter:8333';
        SET s3_url_style = 'path';
        SET s3_use_ssl = false;
        CALL start_ui_server();
        SQLEOF

        cat >> "$INIT" << EOF
        SET s3_access_key_id = '$S3_KEY';
        SET s3_secret_access_key = '$S3_SECRET';
        ATTACH 'postgres://ducklake:$DB_PASS@jupiter:5432/ducklake_catalog' AS ducklake (TYPE postgres);
        EOF

        exec duckdb -init "$INIT"
      '';
    };
  };
}