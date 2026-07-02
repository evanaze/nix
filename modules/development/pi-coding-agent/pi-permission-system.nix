let
  module = {username, ...}: {
    home-manager.users.${username} = {
      home.file.".pi/agent/extensions/pi-permission-system/config.json".text = builtins.toJSON {
        "$schema" = "https://raw.githubusercontent.com/gotgenes/pi-permission-system/main/schemas/permissions.schema.json";
        permissionReviewLog = true;
        yoloMode = false;
        toolInputPreviewMaxLength = 800;
        toolTextSummaryMaxLength = 160;
        permission = {
          "*" = "ask";
          path = {
            "*" = "allow";
            "*.env" = "deny";
            "*.env.*" = "deny";
            "*.env.example" = "allow";
            "~/.config/sops/age/*" = "deny";
            "~/.config/sops/age/keys.txt" = "deny";
            "~/.ssh/*" = "deny";
            "~/.gnupg/*" = "deny";
            "/var/lib/sops-nix/*" = "deny";
          };
          read = "allow";
          grep = "allow";
          find = "allow";
          ls = "allow";
          web_search = "allow";
          web_fetch = "allow";
          ast_grep_search = "allow";
          hypa_grep = "allow";
          hypa_read = "allow";
          hypa_find = "allow";
          hypa_ls = "allow";
          hypa_shell = "ask";
          remnic."*" = "allow";
          ask_user_question = "allow";
          todo = "allow";
          lens_diagnostics = "allow";
          lsp_diagnostics = "allow";
          lsp_navigation = "allow";
          module_report = "allow";
          read_symbol = "allow";
          read_enclosing = "allow";
          edit = "ask";
          write = "ask";
          bash = {
            "*" = "ask";
            "pwd" = "allow";
            "true" = "allow";
            "echo *" = "allow";
            "printf *" = "allow";
            "which *" = "allow";
            "command -v *" = "allow";
            "type *" = "allow";
            "alias *" = "allow";
            "ls *" = "allow";
            "cat *" = "allow";
            "head *" = "allow";
            "tail *" = "allow";
            "sort *" = "allow";
            "wc *" = "allow";
            "file *" = "allow";
            "readlink -f *" = "allow";
            "readelf -l *" = "allow";
            "patchelf --print-*" = "allow";
            "grep *" = "allow";
            "rg *" = "allow";
            "find *" = "allow";
            "find * -exec *" = "ask";
            "find * -delete*" = {
              action = "deny";
              reason = "Refusing destructive find deletion.";
            };
            "git status*" = "allow";
            "git diff*" = "allow";
            "git branch*" = "allow";
            "git log --oneline*" = "allow";
            "git rev-parse*" = "allow";
            "git remote -v*" = "allow";
            "git show*" = "allow";
            "git blame*" = "allow";
            "git describe*" = "allow";
            "git grep*" = "allow";
            "git ls-files*" = "allow";
            "nix flake show*" = "allow";
            "nix flake metadata*" = "allow";
            "nix eval --json*" = "allow";
            "nix profile list*" = "allow";
            "nix profile show*" = "allow";
            "nix path-info*" = "allow";
            "nix search*" = "allow";
            "nix build*" = "allow";
            "nix-instantiate --eval*" = "allow";
            "nix show-config*" = "allow";
            "node --version" = "allow";
            "systemctl --user status*" = "allow";
            "systemctl --user is-enabled*" = "allow";
            "systemctl --user list-unit-files*" = "allow";
            "systemctl --user list-units*" = "allow";
            "systemctl --user show*" = "allow";
            "/run/current-system/sw/bin/systemd-analyze --user verify*" = "allow";
            "systemd-analyze --user verify*" = "allow";
            "journalctl --user *" = "allow";
            "pgrep -a -f *" = "allow";
            "ss -ltnp*" = "allow";
            "rm -r *" = {
              action = "deny";
              reason = "Refusing destructive recursive deletion.";
            };
            "rm -fr *" = {
              action = "deny";
              reason = "Refusing destructive recursive deletion.";
            };
            "rm -rf *" = {
              action = "deny";
              reason = "Refusing destructive recursive deletion.";
            };
            "sudo *" = {
              action = "deny";
              reason = "Refusing privilege escalation from Pi.";
            };
            "git reset --hard*" = {
              action = "deny";
              reason = "Refusing destructive git history rewrites.";
            };
            "git clean -fd*" = {
              action = "deny";
              reason = "Refusing destructive git clean operations.";
            };
            "curl * | sh" = {
              action = "deny";
              reason = "Refusing piped shell installers.";
            };
            "curl * | bash" = {
              action = "deny";
              reason = "Refusing piped shell installers.";
            };
            "wget * | sh" = {
              action = "deny";
              reason = "Refusing piped shell installers.";
            };
            "wget * | bash" = {
              action = "deny";
              reason = "Refusing piped shell installers.";
            };
            "npm install -g *" = {
              action = "deny";
              reason = "Use the nix way to build npm packages: https://wiki.nixos.org/w/index.php?title=Node.js";
            };
          };
          mcp = {
            "*" = "ask";
            mcp_status = "allow";
            mcp_list = "allow";
          };
          skill = {
            "*" = "ask";
          };
          external_directory = {
            "*" = "ask";
            write = "allow";
            "/nix/store/*" = "allow";
            "/nix/var/nix/profiles/*" = "allow";
            "/run/current-system/sw/bin/*" = "allow";
            "~/.pi/agent/*" = "allow";
            "~/.pi-lens/*" = "allow";
            "~/.local/share/remnic/*" = "allow";
            "~/.config/systemd/user/*" = "allow";
            "/etc/systemd/user/*" = "allow";
            "/tmp/*" = "allow";
          };
        };
      };
    };
  };
in {
  flake.modules.nixos = {
    developmentPiAgent = module;
    development = module;
  };
}
