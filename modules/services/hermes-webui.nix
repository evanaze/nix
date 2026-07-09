let
  module = {
    lib,
    pkgs,
    inputs,
    username,
    ...
  }: let
    hermes-webui = pkgs.callPackage ../../pkgs/hermes-webui {
      hermes-agent = pkgs.hermes-agent;
    };
    user-home = "/home/${username}";
    hermes-workspaces = [
      "${user-home}/.config/nix"
      "${user-home}/workspace"
    ];
  in {
    users.users.hermes.extraGroups = [username];

    system.activationScripts.hermesWorkspaceAcl = {
      deps = ["users"];
      text = ''
        setfacl=${pkgs.acl}/bin/setfacl
        find=${pkgs.findutils}/bin/find
        install=${pkgs.coreutils}/bin/install

        grant_workspace_acl() {
          workspace="$1"

          if [ ! -d "$workspace" ]; then
            "$install" -d -m 0750 -o ${username} -g users "$workspace"
          fi

          "$setfacl" -m u:hermes:rwx "$workspace"
          "$find" "$workspace" -type d -exec "$setfacl" -m u:hermes:rwx,d:u:hermes:rwx {} +
          "$find" "$workspace" -type f -perm /111 -exec "$setfacl" -m u:hermes:rwx {} +
          "$find" "$workspace" -type f ! -perm /111 -exec "$setfacl" -m u:hermes:rw {} +
        }

        "$setfacl" -m u:hermes:--x ${user-home}
        "$setfacl" -m u:hermes:--x ${user-home}/.config

        ${lib.concatMapStringsSep "\n" (
            path: "grant_workspace_acl ${lib.escapeShellArg path}"
          )
          hermes-workspaces}
      '';
    };

    systemd.services.hermes-webui = {
      after = [
        "hermes-agent.service"
        "tailscaled.service"
      ];
      wants = ["hermes-agent.service"];
      wantedBy = ["multi-user.target"];
      description = "Hermes WebUI - browser interface for Hermes Agent";
      environment = {
        HERMES_HOME = "/mnt/eye/appdata/hermes/.hermes";
        HERMES_HOME_MODE = "0770";
        HERMES_WEBUI_CHAT_BACKEND = "legacy";
        HERMES_WEBUI_AGENT_DIR = "${inputs.hermes-agent.outPath}";
      };
      serviceConfig = {
        Type = "simple";
        User = "hermes";
        Restart = "on-failure";
        RestartSec = "10s";
      };
      script = "${lib.getExe hermes-webui}";
    };

    systemd.services.agent-tsserve = {
      after = [
        "hermes-webui.service"
        "tailscaled.service"
      ];
      wants = [
        "hermes-webui.service"
        "tailscaled.service"
      ];
      wantedBy = ["multi-user.target"];
      description = "Publish Hermes WebUI via Tailscale Serve";
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        Restart = "on-failure";
        RestartSec = "10s";
      };
      script = ''
        ${lib.getExe pkgs.tailscale} serve clear svc:agent || true
        ${lib.getExe pkgs.tailscale} serve --service=svc:agent --https=443 8787
      '';
    };
  };
in {
  flake.modules.nixos = {
    servicesHermesWebui = module;
    services = module;
  };
}
