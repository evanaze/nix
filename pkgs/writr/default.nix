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
    rev = "aa759a4a423bb4428a24e59a3e7cbc765039e215";
    hash = "sha256-m+If7weBJKgwAqN2lMkFzvVLKuTh1I8KlhHQha/MDAs=";
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
