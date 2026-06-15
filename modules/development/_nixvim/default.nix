_: {
  imports = [
    # General Configuration
    ./settings.nix
    ./keymaps.nix
    ./auto_cmds.nix
    ./file_types.nix

    ./themes # Themes
    ./cmp # Completion
    ./snippets # Snippets
    ./editor # Editor plugins and configurations
    ./ui # UI plugins
    ./lsp # LSP and formatting
    ./git # Git
    ./utils # Utils
  ];
}
