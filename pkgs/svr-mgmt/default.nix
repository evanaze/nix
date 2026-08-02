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
    rev = "c4fcafa9d6a5b9f13b21342ea6cb330601966980";
    hash = "sha256-LLTQsXwEg0SXZi4/WcQrOLVLzbSTta7ICB1SZGkjMBs=";
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
