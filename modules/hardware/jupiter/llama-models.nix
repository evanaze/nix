let
  llamaModelsDir = "/mnt/eye/llama-models";
  module = {
    pkgs,
    lib,
    ...
  }: {
    services.nfs.server = {
      enable = true;
      hostName = "192.168.50.79";
      # NFSv4-only + TCP-only intent
      createMountPoints = false;

      exports = lib.mkForce ''
        ${llamaModelsDir} 192.168.50.203(ro,sync,no_subtree_check,root_squash)
      '';
    };

    services.nfs.settings.nfsd = {
      udp = false;
      tcp = true;
      vers3 = false;
      vers4 = true;
      "vers4.0" = true;
      "vers4.1" = true;
      "vers4.2" = true;
    };

    # Keep export surface small and keep traffic on one TCP NFS port.
    networking.firewall.allowedTCPPorts = [2049];

    systemd.services.llama-models-export-directory = {
      description = "Create llama model export directory on mounted ZFS dataset";
      after = lib.mkForce ["zfs-mount.service"];
      requires = lib.mkForce ["zfs-mount.service"];
      before = [
        "nfs-mountd.service"
        "nfs-server.service"
      ];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
      script = ''
        ${pkgs.coreutils}/bin/mkdir -p ${llamaModelsDir}
        ${pkgs.coreutils}/bin/chown root:root ${llamaModelsDir}
        ${pkgs.coreutils}/bin/chmod 0755 ${llamaModelsDir}
      '';
    };

    systemd.services.nfs-mountd = {
      after = lib.mkForce [
        "zfs-mount.service"
        "llama-models-export-directory.service"
      ];
      requires = lib.mkForce [
        "zfs-mount.service"
        "llama-models-export-directory.service"
      ];
    };

    systemd.services.nfs-server = {
      after = lib.mkForce [
        "zfs-mount.service"
        "nfs-mountd.service"
      ];
      wants = lib.mkForce ["llama-models-export-directory.service"];
      requires = lib.mkForce ["llama-models-export-directory.service"];
    };
  };
in {
  flake.modules.nixos = {
    # Note: do not expose as `hardwareJupiter` to avoid colliding with existing
    # Jupiter hardware feature modules using that key.
    hardwareJupiterLlamaModels = module;
  };
}
