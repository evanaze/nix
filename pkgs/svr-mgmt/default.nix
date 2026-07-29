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
    rev = "304c95c787e9e492904c6e053eb977e8e76e5310";
    hash = "sha256-1uujW3Ihk2kXyCDyBkNfgZu2B7b/+l44A7l0pFz97rs=";
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
