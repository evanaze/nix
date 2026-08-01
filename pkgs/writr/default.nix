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
    rev = "e007458e058d0bf184c655b4b97e2fd02fd9dbb6";
    hash = "sha256-NFeBJ/q0Rx1u+BEWH8rnF2q5F6U6cHOcK6N3fY3iWI0=";
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
