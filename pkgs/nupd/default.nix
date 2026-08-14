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
    rev = "f126351abac93081a7fb50bd66572dc132d049b3";
    hash = lib.fakeHash;
  };

  vendorHash = lib.fakeHash;

  meta = {
    description = "Nix Package Update utility";
    homepage = "https://github.com/evanaze/nupd";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "nupd";
  };
}
