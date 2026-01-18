{pkgs, ...}: {
  imports = [
    ./shared.nix
  ];

  programs.zellij.settings = {
    copy_command = "xclip -selection clipboard";
  };

  programs.zsh.shellAliases = {
    rebuild = "sudo nixos-rebuild switch --flake $HOME/.config/nix#jupiter";
  };
}
