_: {
  imports = [
    # General Configuration
    ./settings.nix
    ./keymaps.nix
    ./auto_cmds.nix
    ./file_types.nix

    ./plugins/themes # Themes
    ./plugins/cmp # Completion
    ./plugins/snippets # Snippets
    ./plugins/editor # Editor plugins and configurations
    ./plugins/ui # UI plugins
    ./plugins/lsp # LSP and formatting
    ./plugins/git # Git
    ./plugins/utils # Utils
  ];
}
