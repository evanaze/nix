{
  perSystem = {pkgs, ...}: {
    packages = {
      twenty = pkgs.callPackage ../pkgs/twenty {};
      hermes-webui = pkgs.callPackage ../pkgs/hermes-webui {};
      oh-my-openagent = pkgs.callPackage ../pkgs/oh-my-openagent {};
      svr-mgmt = pkgs.callPackage ../pkgs/svr-mgmt {};
      # duck-ui = pkgs.callPackage ../pkgs/duck-ui {
      #   bun2nix = inputs.bun2nix.packages.${pkgs.system}.default;
      # };
    };
  };
}
