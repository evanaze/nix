{
  perSystem = {pkgs, ...}: {
    packages = {
      dirac = pkgs.callPackage ../pkgs/dirac {};
      hermes-webui = pkgs.callPackage ../pkgs/hermes-webui {};
      llama-prisma = pkgs.callPackage ../pkgs/llama-prisma {};
      nupd = pkgs.callPackage ../pkgs/nupd {};
      oh-my-openagent = pkgs.callPackage ../pkgs/oh-my-openagent {};
      svr-mgmt = pkgs.callPackage ../pkgs/svr-mgmt {};
      stackmagic-research = pkgs.python313Packages.callPackage ../pkgs/stackmagic-research {};
      writr = pkgs.callPackage ../pkgs/writr {};
    };
  };
}
