{
  pkgs,
  lib,
  username,
  ...
}: {
  environment.systemPackages = with pkgs; [
    illuminanced
  ];

  systemd.services.illuminanced = {
    wantedBy = ["multi-user.target"];
    description = "Service to set screen brightness automatically";
    serviceConfig = {
      Type = "simple";
      User = username;
      Restart = "on-failure";
    };

    script = "${lib.getExe pkgs.illuminanced} -c /home/${username}/.config/nix/aspects/hardware/mars/illuminanced.toml";
  };
}
