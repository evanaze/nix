{
  perSystem = {pkgs, ...}: {
    packages = {
      twenty = pkgs.callPackage ../pkgs/twenty {};
      hermes-webui = pkgs.callPackage ../pkgs/hermes-webui {};
      oh-my-opencode = pkgs.callPackage ../pkgs/oh-my-opencode {};
      # duck-ui = pkgs.callPackage ../pkgs/duck-ui {
      #   bun2nix = inputs.bun2nix.packages.${pkgs.system}.default;
      # };
    };
  };
}
