{
  flake.modules.nixos.businessDuckdbClient = {
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

          export SSL_CERT_FILE="/etc/ssl/certs/ca-certificates.crt"
          export SSL_CERT_DIR="/etc/ssl/certs"

          INIT="$(mktemp)"
          trap 'rm -f "$INIT"' EXIT

          cat > "$INIT" << 'SQLEOF'
          INSTALL httpfs; LOAD httpfs;
          INSTALL ducklake; LOAD ducklake;
          INSTALL ui; LOAD ui;
          INSTALL postgres; LOAD postgres;
          SET s3_region = 'us-east-1';
          SET s3_endpoint = 'swfs.spitz-pickerel.ts.net:8333';
          SET s3_url_style = 'path';
          SET s3_use_ssl = false;
          CALL start_ui();
          SQLEOF

          cat >> "$INIT" << EOF
          SET s3_access_key_id = '$S3_KEY';
          SET s3_secret_access_key = '$S3_SECRET';
          ATTACH 'postgres://ducklake:$DB_PASS@pg.spitz-pickerel.ts.net:5432/stackmagic_catalog' AS stackmagic (TYPE postgres);
          ATTACH 'postgres://ducklake:$DB_PASS@pg.spitz-pickerel.ts.net:5432/de_rec_catalog' AS de_rec (TYPE postgres);
          EOF

          exec duckdb -init "$INIT"
        '';
      };
    };
  };
}
