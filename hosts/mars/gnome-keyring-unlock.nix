# gnome-keyring-unlock.nix
#
# NixOS module for automatic GNOME Keyring unlocking using sops-nix
# Based on: https://codeberg.org/umglurf/gnome-keyring-unlock
#
# This module provides automatic unlocking of GNOME Keyring on login,
# useful for fingerprint/FIDO2 authentication where the keyring
# doesn't get unlocked automatically.
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.gnome-keyring-unlock;

  # Create the unlock script package
  gnome-keyring-unlock = pkgs.python3Packages.buildPythonApplication {
    pname = "gnome-keyring-unlock";
    version = "1.0.0";

    src = pkgs.fetchurl {
      url = "https://codeberg.org/umglurf/gnome-keyring-unlock/raw/branch/main/unlock.py";
      hash = "sha256-6i7V7geddmKjiAhLXy0QpFYJDfPVZshYEQAt0Bl/jE8=";
    };

    dontUnpack = true;
    dontBuild = true;

    installPhase = ''
      mkdir -p $out/bin
      cp $src $out/bin/gnome-keyring-unlock
      chmod +x $out/bin/gnome-keyring-unlock
    '';

    meta = with lib; {
      description = "Script to unlock GNOME Keyring using password from stdin";
      homepage = "https://codeberg.org/umglurf/gnome-keyring-unlock";
      license = licenses.gpl3Plus;
      platforms = platforms.linux;
    };
  };
in {
  options.services.gnome-keyring-unlock = {
    enable = mkEnableOption "automatic GNOME Keyring unlocking on login";

    users = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          sopsSecretPath = mkOption {
            type = types.str;
            description = "Path to the sops secret containing the keyring password";
            example = "gnome-keyring/password";
          };

          autoStart = mkOption {
            type = types.bool;
            default = true;
            description = "Automatically unlock keyring on login";
          };
        };
      });
      default = {};
      description = "Per-user configuration for keyring unlocking";
      example = literalExpression ''
        {
          alice = {
            sopsSecretPath = "gnome-keyring/alice/password";
          };
        }
      '';
    };
  };

  config = mkIf cfg.enable {
    # Install the unlock script
    environment.systemPackages = [gnome-keyring-unlock];

    # Enable GNOME Keyring
    services.gnome.gnome-keyring.enable = mkDefault true;

    # Configure per-user unlock scripts
    home-manager.users = mkMerge (
      mapAttrsToList (username: userCfg: {
        ${username} = {
          # Add profile configuration for automatic unlock
          home.file.".profile-gnome-keyring-unlock" = mkIf userCfg.autoStart {
            text = ''
              # Automatic GNOME Keyring unlock via sops-nix
              if [ -f "${config.sops.secrets."${userCfg.sopsSecretPath}".path}" ]; then
                if ! [ -S "/run/user/$UID/keyring/control" ]; then
                  gnome-keyring-daemon --start --components=secrets >/dev/null 2>&1
                fi

                cat "${config.sops.secrets."${userCfg.sopsSecretPath}".path}" | gnome-keyring-unlock
              fi
            '';
            executable = false;
          };

          # Source the unlock script from profile
          programs.bash.initExtra = mkIf userCfg.autoStart ''
            [ -f ~/.profile-gnome-keyring-unlock ] && source ~/.profile-gnome-keyring-unlock
          '';

          programs.zsh.initExtra = mkIf userCfg.autoStart ''
            [ -f ~/.profile-gnome-keyring-unlock ] && source ~/.profile-gnome-keyring-unlock
          '';
        };
      })
      cfg.users
    );

    # Configure sops secrets
    sops.secrets = mkMerge (
      mapAttrsToList (username: userCfg: {
        "${userCfg.sopsSecretPath}" = {
          owner = username;
          mode = "0400";
        };
      })
      cfg.users
    );
  };
}
