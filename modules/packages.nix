{
  perSystem = {pkgs, ...}: {
    packages = {
      odysseus = pkgs.callPackage ../pkgs/odysseus {};
      firecrawl-source = pkgs.callPackage ../pkgs/firecrawl-source {};
      twenty = pkgs.callPackage ../pkgs/twenty {};
      hermes-webui = pkgs.callPackage ../pkgs/hermes-webui {};
      kestra = pkgs.callPackage ../pkgs/kestra {};
      oh-my-opencode = pkgs.callPackage ../pkgs/oh-my-opencode {};
      svr-mgmt = pkgs.callPackage ../pkgs/svr-mgmt {};
      # duck-ui = pkgs.callPackage ../pkgs/duck-ui {
      #   bun2nix = inputs.bun2nix.packages.${pkgs.system}.default;
      # };
    };
  };
}
