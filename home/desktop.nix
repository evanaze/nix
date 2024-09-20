{pkgs, ...}: {
  imports = [./shared.nix];

  home.packages = with pkgs; [
    brave
    obsidian
    spotify
    steam
  ];

  programs.zellij.settings = {
    copy_command = "xclip -selection clipboard";
  };

  programs.zsh.shellAliases = {
    rebuild = "sudo nixos-rebuild switch --flake $HOME/.config/nix#nixos";
  };
}
