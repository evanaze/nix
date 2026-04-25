{...}: {
  systemd.mounts = [
    {
      what = "/mnt/eye/media/music";
      where = "/home/evanaze/Music";
      type = "none";
      wantedBy = [ "syncthing.service" ];
      before = [ "syncthing.service" ];
      mountConfig = {
        Options = "bind";
      };
    }
    {
      what = "/mnt/eye/documents";
      where = "/home/evanaze/Documents";
      type = "none";
      wantedBy = [ "syncthing.service" ];
      before = [ "syncthing.service" ];
      mountConfig = {
        Options = "bind";
      };
    }
    {
      what = "/mnt/eye/downloads";
      where = "/home/evanaze/Downloads";
      type = "none";
      wantedBy = [ "syncthing.service" ];
      before = [ "syncthing.service" ];
      mountConfig = {
        Options = "bind";
      };
    }
  ];
}
    {
      what = "/mnt/eye/documents";
      where = "/home/evanaze/Documents";
      type = "none";
      wantedBy = [ "syncthing.service" ];
      before = [ "syncthing.service" ];
      mountConfig = {
        Options = "bind";
      };
    }
    {
      what = "/mnt/eye/downloads";
      where = "/home/evanaze/Downloads";
      type = "none";
      wantedBy = [ "syncthing.service" ];
      before = [ "syncthing.service" ];
      mountConfig = {
        Options = "bind";
      };
    }
  ];
}
