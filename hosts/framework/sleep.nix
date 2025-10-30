# Disable wifi and bluetooth before suspend to reduce battery draw in sleep
{pkgs, ...}: {
  systemd.services.preparesleep = {
    enable = true;
    wantedBy = ["sleep.target"];
    before = ["sleep.target"];
    description = "Disable wifi and bluetooth before suspend to reduce battery draw in sleep";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.util-linux}/bin/rfkill block all";
      ExecStop = "${pkgs.util-linux}/bin/rfkill unblock all";
    };
  };
}
