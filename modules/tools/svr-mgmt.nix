let
  module = {
    config,
    lib,
    pkgs,
    username,
    ...
  }: let
    svr-mgmt = pkgs.callPackage ../../pkgs/svr-mgmt {};
    envFile = config.sops.secrets."svr-mgmt/env".path;
    svr-mgmt-with-env = pkgs.writeShellApplication {
      name = "svr-mgmt";
      text = ''
        if [ ! -f "${envFile}" ]; then
          echo "svr-mgmt env file not found: ${envFile}" >&2
          exit 1
        fi

        set -a
        # shellcheck source=/dev/null
        . "${envFile}"
        set +a

        exec ${lib.getExe svr-mgmt} "$@"
      '';
    };
  in {
    environment.systemPackages = [svr-mgmt-with-env];

    # Expected dotenv contents:
    # GLKVM_USER=admin
    # GLKVM_PASSWORD=...
    # GLKVM_URL=https://ai-kvm.spitz-pickerel.ts.net
    sops.secrets."svr-mgmt/env" = {
      owner = username;
      mode = "0400";
    };
  };
in {
  flake.modules.nixos = {
    toolsSvrMgmt = module;
    tools = module;
  };
}
