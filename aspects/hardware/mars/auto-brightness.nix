{
  pkgs,
  lib,
  username,
  ...
}: {
  environment.systemPackages = [pkgs.illuminanced];

  systemd.services.illuminanced = {
    wantedBy = ["multi-user.target"];
    description = "Service to set screen brightness automatically";
    serviceConfig = {
      Type = "forking";
      Restart = "on-failure";
      PIDFile = "/run/illuminanced.pid";
    };

    script = "${lib.getExe pkgs.illuminanced} -c ${./illuminanced.toml}";
  };
}
