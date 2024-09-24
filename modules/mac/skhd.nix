{pkgs, ...}: {
  environment = {
    systemPackages = with pkgs; [
      skhd
    ];
  };

  services.skhd = {
    enable = true;
    skhdConfig = ''
      # change focus
      alt - h : yabai -m window --focus west
      alt - j : yabai -m window --focus south
      alt - k : yabai -m window --focus north
      alt - l : yabai -m window --focus east

      # focus on the selected space
      alt - 1 : yabai -m space --focus 1
      alt - 2 : yabai -m space --focus 2
      alt - 3 : yabai -m space --focus 3
      alt - 4 : yabai -m space --focus 4
      alt - 5 : yabai -m space --focus 5
      alt - 6 : yabai -m space --focus 6
      alt - 7 : yabai -m space --focus 7
      alt - 8 : yabai -m space --focus 8
      alt - 9 : yabai -m space --focus 9

      # go back to previous workspace (kind of like back_and_forth in i3)
      alt - b : yabai -m space --focus recent
      alt - n : yabai -m space --focus next
      alt - p : yabai -m space --focus prev

      # move focused window to next/prev workspace
      alt + shift - 1 : yabai -m window --space 1
      alt + shift - 2 : yabai -m window --space 2
      alt + shift - 3 : yabai -m window --space 3
      alt + shift - 4 : yabai -m window --space 4
      alt + shift - 5 : yabai -m window --space 5
      alt + shift - 6 : yabai -m window --space 6
      alt + shift - 7 : yabai -m window --space 7
      alt + shift - 8 : yabai -m window --space 8
      alt + shift - 9 : yabai -m window --space 9

      # enter fullscreen mode for the focused container
      alt - f : yabai -m window --toggle zoom-fullscreen

      # toggle window native fullscreen
      alt + shift - f : yabai -m window --toggle native-fullscreen

      # Custom keybindings
      cmd - return : open -n /Applications/iTerm.app
    '';
  };
}
