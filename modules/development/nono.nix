let
  nonoPiPackInstall = pkgs:
    pkgs.writeShellApplication {
      name = "nono-pi-pack-install";
      runtimeInputs = [
        pkgs.gnugrep
        pkgs.nono
      ];
      text = ''
        set -euo pipefail

        if nono list --installed 2>/dev/null | grep -Fq "nolabs-ai/pi"; then
          exit 0
        fi

        if nono pull nolabs-ai/pi; then
          exit 0
        fi

        nono pull nolabs-ai/pi --force
      '';
    };

  module = {
    pkgs,
    username,
    ...
  }: {
    environment.systemPackages = with pkgs; [
      nono
    ];

    home-manager.users.${username} = {lib, ...}: {
      home.file.".config/nono/profiles/pi.json".text = builtins.toJSON {
        extends = "nolabs-ai/pi";
        meta = {
          name = "pi";
        };
        groups = {
          include = [];
          exclude = [];
        };
        commands = {
          allow = [];
          deny = [];
        };
        workdir = {
          access = "readwrite";
        };
        filesystem = {
          allow = [];
          read = [
            "/tmp"
          ];
          write = [];
          allow_file = [
            "/dev/kvm"
            "/run/secrets/nocodb/env"
            "/home/evanaze/.pi-lens/sessionstart.log"
            "/home/evanaze/.config/rpiv-web-tools/config.json"
          ];
          read_file = [];
          write_file = [];
          deny = [];
          bypass_protection = [];
          suppress_save_prompt = [];
        };
        network = {
          block = false;
          allow_domain = [];
          credentials = [];
          open_port = [];
          listen_port = [];
          custom_credentials = {};
        };
        env_credentials = {};
        hooks = {};
        rollback = {
          exclude_patterns = [];
          exclude_globs = [];
        };
      };

      home.activation.nonoPiPackInstall = lib.hm.dag.entryAfter ["writeBoundary"] ''
        ${nonoPiPackInstall pkgs}/bin/nono-pi-pack-install
      '';
    };
  };
in {
  flake.modules.nixos = {
    developmentNono = module;
    development = module;
  };
}
