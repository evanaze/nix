let
  module =
    # aspects/development/editors.nix - Editors and terminal tools (nixvim, ghostty, zellij)
    {
      pkgs,
      config,
      inputs,
      username,
      system,
      ...
    }: let
      nixvim' = inputs.nixvim.legacyPackages.${system};
      nvim = nixvim'.makeNixvimWithModule {
        inherit pkgs;
        module = ./_nixvim;
      };
    in {
      nixpkgs.overlays = [inputs.ghostty.overlays.default];

      # Home-manager editor configuration
      home-manager.users.${username} = {
        home.packages = [
          nvim
        ];

        programs = {
          ghostty = {
            enable = true;
            enableZshIntegration = true;
            # The ghostty flake's own `pkgs.ghostty` derivation (nix/package.nix)
            # requires a `zig_0_17` argument that is never wired into the
            # flake's `packages` function, so evaluating its default aborts
            # ("Function called without required argument zig_0_17"). Use the
            # stable, maintained nixpkgs `ghostty` package instead.
            package = inputs.nixpkgs.legacyPackages.${system}.ghostty;
            installVimSyntax = true;
            settings = {
              font-family = "Iosevka";
              theme = "Catppuccin Macchiato";
              background-opacity = 0.96;
            };
          };

          zellij = {
            enable = true;
            enableZshIntegration = true;
            settings = {
              theme = "catppuccin-macchiato";
              advanced_mouse_actions = false;
            };
          };
        };
      };
    };
in {
  flake.modules.nixos = {
    developmentEditors = module;
    development = module;
  };
}
