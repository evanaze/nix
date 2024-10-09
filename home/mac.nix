{...}: {
  imports = [./shared.nix];

  programs.zellij.settings = {
    copy_command = "pbcopy";
  };

  programs.zsh.shellAliases = {
    rebuild = "darwin-rebuild switch --flake $HOME/.config/nix#cooper";
    erebuild = "nix run nix-darwin -- switch --flake $HOME/.config/nix#cooper";
  };
}
