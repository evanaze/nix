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
      # Completion for the ducklake wrapper. home-manager's programs.zsh.enableCompletion
      # (set in modules/development/zsh.nix) puts $XDG_DATA_HOME/zsh/site-functions on
      # fpath automatically, so a file named `_ducklake` under .config/zsh/site-functions
      # gets symlinked there and just works.
      home.file.".config/zsh/site-functions/_ducklake" = {
        text = ''
          #compdef ducklake

          _ducklake() {
            local -a options
            options=(
              '(-c --command)'{-c,--command}'[run SQL from string]:SQL string:'
              '(-f --file)'{-f,--file}'[run SQL from file]:file:_files'
              '(-init)'--init'[read SQL from file before starting REPL]:file:_files'
              '(-read-only)'--read-only'[open database read-only]'
              '(-csv -json)'{-csv,-json}'[output format]'
              '(-header -noheader)'{-header,-noheader}'[show/hide column headers]'
              '(-list -line -column)'{-list,-line,-column}'[output mode]'
              '(-s)'{-s,--sql}'[run SQL statement]:SQL string:'
              '(-no-stdin)'--no-stdin'[do not read from stdin]'
              '(-list)'--list'[list available extensions]'
              '1:database file:_files'
              '*::argument:_files'
            )
            _arguments -C $options
          }

          _ducklake "$@"
        '';
      };

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
          ATTACH 'ducklake:postgres:postgresql://stackmagic_catalog:$DB_PASS@pg.spitz-pickerel.ts.net:5432/stackmagic_catalog' AS stackmagic;
          ATTACH 'ducklake:postgres:postgresql://de_rec_catalog:$DB_PASS@pg.spitz-pickerel.ts.net:5432/de_rec_catalog' AS de_rec;
          EOF

          exec duckdb -init "$INIT"
        '';
      };
    };
  };
}
