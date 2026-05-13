# aspects/media/jellyfin.nix - Jellyfin media server
{
  lib,
  pkgs,
  config,
  ...
}: {
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      rocmPackages.clr.icd # OpenCL for AMD
      libva-utils
      libva-vdpau-driver
      libvdpau-va-gl
    ];
  };

  nixflix = {
    enable = true;
    mediaDir = "/mnt/eye/media";
    caddy.enable = true;
    postgres.enable = true;
    sonarr = {
      enable = true;
      config = {
        apiKey = {
          _secret = config.sops.secrets."sonarr/api_key".path;
        };
        hostConfig.password = {
          _secret = config.sops.secrets."sonarr/password".path;
        };
      };
    };

    radarr = {
      enable = true;
      config = {
        apiKey = {
          _secret = config.sops.secrets."radarr/api_key".path;
        };
        hostConfig.password = {
          _secret = config.sops.secrets."radarr/password".path;
        };
      };
    };

    prowlarr = {
      enable = true;
      config = {
        apiKey = {
          _secret = config.sops.secrets."prowlarr/api_key".path;
        };
        hostConfig.password = {
          _secret = config.sops.secrets."prowlarr/password".path;
        };
      };
    };

    sabnzbd = {
      enable = true;
      settings = {
        misc.api_key = {
          _secret = config.sops.secrets."sabnzbd/api_key".path;
        };
      };
    };

    jellyfin = {
      enable = true;
      users.admin = {
        policy.isAdministrator = true;
        password = {
          _secret = config.sops.secrets."jellyfin/admin_password".path;
        };
      };
    };
  };

  systemd.services.jellyfin-tsserve = {
    after = [
      "tailscaled-autoconnect.service"
      "jellyfin.service"
    ];
    wants = [
      "tailscaled-autoconnect.service"
      "jellyfin.service"
    ];
    wantedBy = ["multi-user.target"];
    description = "Using Tailscale Serve to publish Jellyfin";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = "${lib.getExe pkgs.tailscale} serve --service=svc:media --https=4433 8096";
  };
}
