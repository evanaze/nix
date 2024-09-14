{pkgs, ...}: {
  environment = {
    systemPackages = with pkgs; [
      yabai
    ];
  };

  services.yabai = {
    enable = true;
    enableScriptingAddition = true;

    config = {
      layout = "bsp";
      window_placement = "second_child";
      window_shadow = "off";
      mouse_follows_focus = "on";
      focus_follows_mouse = "autofocus";
      window_opacity = "off";

      top_padding = 10;
      bottom_padding = 10;
      left_padding = 10;
      right_padding = 10;
      window_gap = 6;

      extraConfig = ''
        # spaces
        yabai -m space 1 --label terminal
        yabai -m space 2 --label browsing
        yabai -m space 3 --label notes
        yabai -m space 4 --label media
        yabai -m space 5 --label mail
        yabai -m space 6 --label mail

        # rules
        yabai -m rule --add app='^Installer$'           manage=off
        yabai -m rule --add app='^Messages$'            manage=off
        yabai -m rule --add app='^System Information$'  manage=off
        yabai -m rule --add app='^System Settings$'     manage=off
        yabai -m rule --add app='^Finder$'              manage=off
        yabai -m rule --add app='^Calculator$'          manage=off
        yabai -m rule --add title='Preferences$'        manage=off
        yabai -m rule --add app='^iTerm2$'              space=terminal
        yabai -m rule --add app='^Brave.*$'             space=browsing
        yabai -m rule --add app='^Obsidian$'            space=notes
        yabai -m rule --add app='^Spotify$'             space=media
        yabai -m rule --add app='^Mail$'                space=mail
        yabai -m rule --add app='^Sorted$'              space=^6

        # Load scripting addition
        # yabai -m signal --add event=dock_did_restart \
        #   action="sudo yabai --load-sa"
        # sudo yabai --load-sa
      '';
    };
  };
}
