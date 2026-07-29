{
  buildGoModule,
  fetchFromGitHub,
  lib,
}:
buildGoModule {
  pname = "svr-mgmt";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "evanaze";
    repo = "svr-mgmt";
    rev = "615932dcaef20656480db09d061a8c19404f0c88";
    hash = "sha256-1XhVKnS6IcmcNuUPfmztEITfIZxW4L51w6dtqkYd5MQ=";
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
