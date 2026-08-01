{
  perSystem = {pkgs, ...}: {
    packages = {
      dragonfly-gguf-client = pkgs.callPackage ../pkgs/dragonfly-gguf-client {};
      twenty = pkgs.callPackage ../pkgs/twenty {};
      hermes-webui = pkgs.callPackage ../pkgs/hermes-webui {};
      oh-my-openagent = pkgs.callPackage ../pkgs/oh-my-openagent {};
      svr-mgmt = pkgs.callPackage ../pkgs/svr-mgmt {};
      llama-prisma = pkgs.callPackage ../pkgs/llama-prisma {};
      dirac = pkgs.callPackage ../pkgs/dirac {};
      writr = pkgs.callPackage ../pkgs/writr {};
      # duck-ui = pkgs.callPackage ../pkgs/duck-ui {
      #   bun2nix = inputs.bun2nix.packages.${pkgs.system}.default;
      # };
    };
  };
}
