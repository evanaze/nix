{pkgs, ...}: {
  home.packages = with pkgs; [
    brave
    obsidian
    spotify
    steam
  ];

  programs.zellij.settings = {
    copy_command = "xclip -selection clipboard";
  };
}
