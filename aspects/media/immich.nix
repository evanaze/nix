{username, ...}: {
  users.groups.media = {};

  users.users.${username}.extraGroups = ["media"];

  services.immich = {
    enable = true;
    group = "media";
    port = 2283;
    mediaLocation = "/mnt/eye/pictures";
  };
}
