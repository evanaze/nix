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
    description = "Automatic screen brightness setting";
    serviceConfig = {
      Type = "simple";
      User = username;
      ExecStart = lib.getExe pkgs.illuminanced;
      Restart = "on-failure";
    };
  };
}
