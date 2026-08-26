{
  perSystem = {pkgs, ...}: let
    sqlmeshPkgs = pkgs.python313Packages.override {
      overrides = self: super: {
        sqlglot = self.callPackage ../pkgs/sqlmesh/sqlglot.nix {};
        hyperscript = self.callPackage ../pkgs/sqlmesh/hyperscript.nix {};
        dateparser = self.callPackage ../pkgs/sqlmesh/dateparser.nix {};
      };
    };
  in {
    packages = {
      dirac = pkgs.callPackage ../pkgs/dirac {};
      hermes-webui = pkgs.callPackage ../pkgs/hermes-webui {};
      llama-prisma = pkgs.callPackage ../pkgs/llama-prisma {};
      nupd = pkgs.callPackage ../pkgs/nupd {};
      svr-mgmt = pkgs.callPackage ../pkgs/svr-mgmt {};
      stackmagic-research = pkgs.python313Packages.callPackage ../pkgs/stackmagic-research {};
      writr = pkgs.callPackage ../pkgs/writr {};
      sqlmesh = sqlmeshPkgs.callPackage ../pkgs/sqlmesh/default.nix {};
    };
  };
}
