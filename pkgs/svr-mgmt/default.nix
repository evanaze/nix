{
  buildGoModule,
  fetchFromGitHub,
  lib,
}:
buildGoModule {
  pname = "svr-mgmt";
  version = "0-unstable-2026-07-07";

  src = fetchFromGitHub {
    owner = "evanaze";
    repo = "svr-mgmt";
    rev = "1fa2ce85521d3611e96582277ebcb82b76768cd3";
    hash = "sha256-nN8AQxbCp6ZH5ceMVC7YnlDZgXlOSOvbE9JQfm29lZM=";
  };

  vendorHash = null;

  meta = {
    description = "Small Go CLI for controlling a server's ATX power through a GL.iNet GLKVM Comet";
    homepage = "https://github.com/evanaze/svr-mgmt";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "svr-mgmt";
  };
}
