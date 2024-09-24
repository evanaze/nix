{...}: {
  imports = [./shared.nix];

  programs.zellij.settings = {
    copy_command = "pbcopy";
  };

  programs.zsh.shellAliases = {
    rebuild = "darwin-rebuild switch --flake $HOME/.config/nix#mac";
    erebuild = "nix run darwin-rebuild -- switch --flake $HOME/.config/nix#mac";
  };
}
