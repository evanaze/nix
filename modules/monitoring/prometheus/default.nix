{
  flake.modules.nixos.prometheus =
    # aspects/monitoring/prometheus.nix - Prometheus monitoring
    {config, ...}: {
      services.prometheus = {
        enable = true;
        port = 9001;

        globalConfig.scrape_interval = "15s";

        scrapeConfigs = [
          {
            job_name = "nodes";
            static_configs = [
              {
                targets = ["127.0.0.1:${toString config.services.prometheus.exporters.node.port}"];
                labels.host = "jupiter";
              }
              {
                targets = ["earth.spitz-pickerel.ts.net:9002"];
                labels.host = "earth";
              }
              {
                targets = ["mars.spitz-pickerel.ts.net:9002"];
                labels.host = "mars";
              }
              {
                targets = ["mercury.spitz-pickerel.ts.net:9002"];
                labels.host = "mercury";
              }
            ];
          }
          {
            job_name = "restic";
            static_configs = [
              {
                targets = ["127.0.0.1:${toString config.services.prometheus.exporters.restic.port}"];
                labels.host = "jupiter";
              }
            ];
          }
          {
            job_name = "smartctl";
            static_configs = [
              {
                targets = ["127.0.0.1:${toString config.services.prometheus.exporters.smartctl.port}"];
                labels.host = "jupiter";
              }
            ];
          }
          {
            job_name = "postgres";
            static_configs = [
              {
                targets = ["127.0.0.1:${toString config.services.prometheus.exporters.postgres.port}"];
                labels.host = "jupiter";
              }
            ];
          }
        ];

        rules = [
          ''
            groups:
              - name: server-health
                rules:
                  - alert: InstanceDown
                    expr: up == 0
                    for: 5m
                    labels:
                      severity: critical
                    annotations:
                      summary: "{{ $labels.host }} is down"
                      description: "Prometheus has been unable to scrape {{ $labels.job }} on {{ $labels.host }} for 5 minutes."

                  - alert: HighDiskUsage
                    expr: 100 * (1 - node_filesystem_avail_bytes{fstype!~"tmpfs|devtmpfs|overlay|squashfs"} / node_filesystem_size_bytes{fstype!~"tmpfs|devtmpfs|overlay|squashfs"}) > 90
                    for: 15m
                    labels:
                      severity: warning
                    annotations:
                      summary: "{{ $labels.host }} disk usage is high"
                      description: "{{ $labels.mountpoint }} on {{ $labels.host }} is above 90% used."

                  - alert: LowDiskSpace
                    expr: node_filesystem_avail_bytes{fstype!~"tmpfs|devtmpfs|overlay|squashfs"} < 10 * 1024 * 1024 * 1024
                    for: 15m
                    labels:
                      severity: warning
                    annotations:
                      summary: "{{ $labels.host }} disk space is low"
                      description: "{{ $labels.mountpoint }} on {{ $labels.host }} has less than 10 GiB available."

                  - alert: SystemdUnitFailed
                    expr: node_systemd_unit_state{state="failed"} > 0
                    for: 5m
                    labels:
                      severity: warning
                    annotations:
                      summary: "{{ $labels.host }} has a failed systemd unit"
                      description: "{{ $labels.name }} is failed on {{ $labels.host }}."

                  - alert: SmartDeviceUnhealthy
                    expr: smartctl_device_smart_status != 1
                    for: 15m
                    labels:
                      severity: critical
                    annotations:
                      summary: "{{ $labels.host }} SMART health check failed"
                      description: "SMART health status is unhealthy for {{ $labels.device }} on {{ $labels.host }}."

                  - alert: ZfsPoolUnhealthy
                    expr: zfs_pools_healthy{host="jupiter"} == 0
                    for: 5m
                    labels:
                      severity: critical
                    annotations:
                      summary: "jupiter ZFS pool health check failed"
                      description: "zpool status -x reports that one or more imported ZFS pools on jupiter are not healthy."

                  - alert: ZfsPoolHealthMissing
                    expr: absent(zfs_pools_healthy{host="jupiter"})
                    for: 10m
                    labels:
                      severity: warning
                    annotations:
                      summary: "jupiter ZFS pool health metric is missing"
                      description: "Prometheus is not receiving the zfs_pools_healthy metric from jupiter."
          ''
        ];
      };
    };
}
