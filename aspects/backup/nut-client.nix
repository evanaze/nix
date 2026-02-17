{config, ...}: {
  power.ups = {
    enable = true;
    mode = "netclient";

    upsmon.monitor."UPS-1" = {
      # Connect to the NUT server via Tailscale MagicDNS
      system = "UPS-1@jupiter";
      powerValue = 1;
      user = "nut-client";
      passwordFile = config.sops.secrets."nut/ups-passwd".path;
      type = "secondary";
    };

    upsmon.settings = {
      # Shut down immediately when signaled
      FINALDELAY = 0;
    };
  };
}
