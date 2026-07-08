let
  module = {
    pkgs,
    username,
    ...
  }: let
    gondolinExtensionPackage = pkgs.buildNpmPackage {
      pname = "pi-extension-gondolin";
      version = "0.80.3";
      src = ./gondolin-extension;
      npmDepsHash = "sha256-GY6D2YKEzAr112RiG6Z5uaF/pyGQzA8r6HEvphqBJBo=";
      dontNpmBuild = true;

      installPhase = ''
        runHook preInstall
        mkdir -p $out
        cp -r index.ts package.json package-lock.json node_modules $out/
        runHook postInstall
      '';
    };
  in {
    home-manager.users.${username}.programs.pi-coding-agent = {
      extraPackages = [pkgs.qemu];
      settings.packages = ["${gondolinExtensionPackage}"];
    };
  };
in {
  flake.modules.nixos = {
    developmentPiAgent = module;
    development = module;
  };
}
