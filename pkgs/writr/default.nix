{
  buildGoModule,
  fetchFromGitHub,
  lib,
}:
buildGoModule {
  pname = "writr";
  version = "0.1.0";

  mainModule = "github.com/writr";

  src = fetchFromGitHub {
    owner = "evanaze";
    repo = "writr";
    rev = "5b474643771b57fa3c1a226b8cfc80d2ebf2d6c9";
    hash = "sha256-3mnyCHDOXcqg+lRDZ1Cezg606SGh9YIicJPI0SAK1ps=";
  };

  vendorHash = "sha256-lshVybtUjJE3Pa5/XBy7ya5t/i+VhnO/C8jRjQf7Dks=";

  meta = {
    description = "Minimal markdown journaling / writing web app with a local SQLite store";
    homepage = "https://github.com/evanaze/writr";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "writr";
  };
}
