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
    rev = "f58bbecc3f726650d6bb0a85ec9fa95666c2713c";
    hash = "sha256-iht86aOJ4PQCB9pbS2byq7dQ+b36fmegHpNAqR/dM0M=";
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
