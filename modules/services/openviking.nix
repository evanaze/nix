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

    services.tailscale.serve.services.memory.endpoints."tcp:443" = "http://localhost:1933";
  };
in {
  flake.modules.nixos = {
    servicesOpenviking = module;
  };
}
