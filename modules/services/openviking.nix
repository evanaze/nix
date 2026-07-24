let
  openvikingCompatOverlay = inputs: final: prev: {
    openviking = final.callPackage ../../pkgs/openviking/package.nix {
      inherit (prev.openviking) src version;
      ov-cli = final.ov-cli;
      ragfs-python = inputs.openviking.packages.${final.stdenv.hostPlatform.system}.ragfs-python;
    };
  };

  module = {
    pkgs,
    lib,
    config,
    inputs,
    ...
  }: {
    nixpkgs.overlays = [
      inputs.openviking.overlays.default
      (openvikingCompatOverlay inputs)
    ];

    environment.systemPackages = with pkgs; [
      openviking
    ];

    services.openviking = {
      enable = true;
      package = pkgs.openviking;
      configFile = config.sops.secrets."openviking/conf".path;
    };

    # Enable the CLI in interactive shells to share state
    # with the service
    environment.variables.OPENVIKING_CONFIG_FILE = config.sops.secrets."openviking/conf".path;

    sops.secrets."openviking/conf" = {
      owner = "openviking";
      group = "users";
      mode = "0440";
    };

    systemd.services.openviking-tsserve = {
      after = [
        "tailscaled-autoconnect.service"
        "openviking.service"
      ];
      wants = [
        "tailscaled-autoconnect.service"
        "openviking.service"
      ];
      wantedBy = ["multi-user.target"];
      description = "Using Tailscale Serve to publish Openviking";
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        Restart = "on-failure";
        RestartSec = "10s";
      };
      script = ''
        ${lib.getExe pkgs.tailscale} serve clear svc:memory || true
        ${lib.getExe pkgs.tailscale} serve --service=svc:memory --https=443 http://localhost:1933
      '';
    };
  };
in {
  flake.modules.nixos = {
    servicesOpenviking = module;
    # services = module;
  };
}
