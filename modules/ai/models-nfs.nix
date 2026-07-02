let
  module = {...}: {
    fileSystems."/mnt/jupiter-llama-models" = {
      device = "192.168.50.79:/mnt/eye/llama-models";
      fsType = "nfs";
      options = [
        "_netdev"
        "ro"
        "nfsvers=4.2"
        "noauto"
        "nofail"
        "x-systemd.automount"
        "x-systemd.idle-timeout=600"
        "noatime"
        "hard"
      ];
    };
  };
in {
  flake.modules.nixos = {
    aiServer = module;
  };
}
