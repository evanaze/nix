{pkgs, ...}: {
  imports = [./shared.nix];

  home.packages = with pkgs; [
    brave
    firefox
    obsidian
    spotify
    steam
  ];

  programs.zellij.settings = {
    copy_command = "xclip -selection clipboard";
  };

  programs.zsh.shellAliases = {
    rebuild = "sudo nixos-rebuild switch --flake $HOME/.config/nix#desktop";
  };

  ssbm.slippi-launcher = {
    enable = true;
    # Replace with the path to your Melee ISO
    isoPath = "$HOME/Downloads/Super Smash Bros. Melee (USA) (En,Ja) (v1.02).iso";
  };
}
