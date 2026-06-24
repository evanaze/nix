let
  module = {config, ...}: {
    sops.secrets."github/token" = {
      owner = "root";
      group = "root";
      mode = "0400";
    };

    sops.templates."nix-github-private.env" = {
      owner = "root";
      group = "root";
      mode = "0400";
      content = ''
        NIX_GITHUB_PRIVATE_USERNAME=x-access-token
        NIX_GITHUB_PRIVATE_PASSWORD=${config.sops.placeholder."github/token"}
      '';
    };

    systemd.services.nix-daemon.serviceConfig.EnvironmentFile = [
      config.sops.templates."nix-github-private.env".path
    ];
  };
in {
  flake.modules.nixos = {
    corePrivateGit = module;
  };
}
