# hosts/jupiter/default.nix - Jupiter (Server) host-specific configuration
{
  pkgs,
  lib,
  ...
}: {
  networking.hostName = "jupiter";

  # Keep awake - disable GDM auto suspend
  services.displayManager.gdm.autoSuspend = false;

  # Tailscale web UI
  services.tailscale = {
    useRoutingFeatures = "server";
    authKeyFile = "/run/secrets/ts-server-key";
    extraSetFlags = ["--webclient"];
  };

  # HDD power management
  environment.systemPackages = with pkgs; [
    hdparm
  ];

  # From https://wiki.nixos.org/wiki/Power_Management
  services.udev.extraRules = let
    mkRule = as: lib.concatStringsSep ", " as;
    mkRules = rs: lib.concatStringsSep "\n" rs;
  in
    mkRules [
      (mkRule [
        ''ACTION=="add|change"''
        ''SUBSYSTEM=="block"''
        ''KERNEL=="sd[a-z]"''
        ''ATTR{queue/rotational}=="1"''
        ''RUN+="${pkgs.hdparm}/bin/hdparm -B 90 -S 41 /dev/%k"''
      ])
    ];

  system.stateVersion = "25.11";
}
