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
    rev = "9c7d28d74de6117a9982b589981c27ca12775a03";
    hash = "sha256-Vm0JZwrvNAHx+Ik7wsnft+vSntKTNKCR4YUgH0Vc5Yc=";
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
