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
    rev = "888b856c87534c34d8e9cbecfb8dd045e3267413";
    hash = "sha256-8vEgGJNSrC16zf92OpRvpewHhmG205hmiY02PwRlcAU=";
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
