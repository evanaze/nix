# aspects/core/sops.nix - Secrets management with sops-nix
{
  pkgs,
  username,
  ...
}: {
  environment.systemPackages = with pkgs; [
    age
    sops
    ssh-to-age
  ];

  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    age = {
      sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
      keyFile = "/home/${username}/.config/sops/age/keys.txt";
      generateKey = true;
    };
    secrets = {
      ts-server-key = {};
      cache-private-key = {};
      openrouter-api-key = {
        owner = username;
      };
      restic-password = {};
      admin-pass = {};
      grafana = {};
      actual = {};
      "nut/ups-passwd" = {};
      "librechat/creds/key" = {};
      "librechat/creds/iv" = {};
      "librechat/jwt/secret" = {};
      "librechat/jwt/refresh_secret" = {};
      "librechat/meili/master_key" = {};
      "syncthing/earth/key" = {};
      "syncthing/earth/cert" = {};
      "syncthing/mars/key" = {};
      "syncthing/mars/cert" = {};
      "syncthing/jupiter/key" = {};
      "syncthing/jupiter/cert" = {};
      # Media
      "sonarr/api_key" = {};
      "sonarr/password" = {};
      "radarr/api_key" = {};
      "radarr/password" = {};
      "lidarr/api_key" = {};
      "lidarr/password" = {};
      "prowlarr/api_key" = {};
      "prowlarr/password" = {};
      "indexer-api-keys/DrunkenSlug" = {};
      "indexer-api-keys/NZBFinder" = {};
      "indexer-api-keys/NzbPlanet" = {};
      "jellyfin/api_key" = {};
      "jellyfin/admin_password" = {};
      "seerr/api_key" = {};
      "wireguard/conf" = {};
      "sabnzbd/api_key" = {};
      "sabnzbd/nzb_key" = {};
      "usenet/eweka/username" = {};
      "usenet/eweka/password" = {};
      "usenet/newsgroupdirect/username" = {};
      "usenet/newsgroupdirect/password" = {};
    };
  };
}
