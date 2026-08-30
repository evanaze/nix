{
  buildGoModule,
  fetchFromGitHub,
  lib,
}:
buildGoModule {
  pname = "nupd";
  version = "0.1.0";

  mainModule = "github.com/nupd";

  src = fetchFromGitHub {
    owner = "evanaze";
    repo = "nupd";
    rev = "d64c32f7bd03997b8520a2e51ebbca9a5f346d06";
    hash = "sha256-naKcpwezYunrM/T0B088D5IA5+ji+3JuCSHbH65qaDI=";
  };

  vendorHash = null;

  meta = {
    description = "Nix Package Update utility";
    homepage = "https://github.com/evanaze/nupd";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "nupd";
  };
}
