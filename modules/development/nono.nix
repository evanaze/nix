let
  module = {
    pkgs,
    username,
    ...
  }: {
    environment.systemPackages = with pkgs; [
      nono
    ];

    home-manager.users.${username}.home.file.".config/nono/profiles/pi.json".text = builtins.toJSON {
      extends = "always-further/pi";
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
  };
in {
  flake.modules.nixos = {
    developmentNono = module;
    development = module;
  };
}
