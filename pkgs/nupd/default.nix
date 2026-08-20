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
    rev = "89557af495e4792e46649af186bb2041dd75427e";
    hash = "sha256-lSmsXnKAxpypVkYD4Q6lKzWgzFqSKD7VCvqDpdQ+5x8=";
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
