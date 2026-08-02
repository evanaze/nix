let
  module =
    # aspects/desktop/gnome.nix - GNOME desktop environment
    {
      pkgs,
      username,
      ...
    }:
    let
      # Caffeine ships its GSettings schema only inside the extension dir
      # (…/caffeine@patapon.info/schemas/), which glib's global lookup on
      # XDG_DATA_DIRS never sees. SymlinkJoin it into the standard
      # glib-2.0/schemas location so standalone `gsettings` can find it.
      caffeineWrapped = pkgs.symlinkJoin {
        name = "caffeine-gnome-extension";
        paths = [pkgs.gnomeExtensions.caffeine];
        postBuild = ''
          mkdir -p $out/share/glib-2.0/schemas
          ln -s \
            $out/share/gnome-shell/extensions/caffeine@patapon.info/schemas/gschemas.compiled \
            $out/share/glib-2.0/schemas/gschemas.compiled
        '';
      };
    in {

      services.desktopManager.gnome.enable = true;

      services.displayManager = {
        autoLogin = {
          enable = false;
          user = username;
        };
        gdm.enable = true;
      };

      environment.systemPackages = [
        caffeineWrapped
      ];

      # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
      systemd.services."getty@tty1".enable = false;
      systemd.services."autovt@tty1".enable = false;

      nixpkgs.config.permittedInsecurePackages = [
        "electron-39.8.10"
      ];

      # Enable GNOME Shell extensions installed via environment.systemPackages.
      # Extensions in the Nix store aren't automatically activated — they must
      # be listed here by UUID to tell GNOME Shell to load them.
      programs.dconf.profiles.user.databases = [
        {
          settings."org/gnome/shell" = {
            enabled-extensions = [
              pkgs.gnomeExtensions.caffeine.extensionUuid
              pkgs.gnomeExtensions.vicinae.extensionUuid
              pkgs.gnomeExtensions.adaptive-brightness.extensionUuid
            ];
          };
        }
      ];
    };
in {
  flake.modules.nixos = {
    desktopGnome = module;
    desktop = module;
  };
}
