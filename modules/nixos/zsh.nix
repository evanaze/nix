{pkgs, ...}: {
  # System-level zsh configuration
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  # System packages needed for zsh functionality
  environment.systemPackages = with pkgs; [
    doppler
    fd
    fzf
    gh
    pass
    pure-prompt
    ripgrep
    zoxide
    zsh-fast-syntax-highlighting
  ];
}
