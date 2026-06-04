{
  stdenv,
  lib,
  fetchFromGitHub,
  python3,
  makeWrapper,
}:
let
  version = "0.51.253";

  src = fetchFromGitHub {
    owner = "nesquena";
    repo = "hermes-webui";
    rev = "v${version}";
    hash = "sha256-khx7TJfP6pZBXHKH3cz2yqbr0CH4vnU3vMNeCNMZ6xI=";
  };

  pythonEnv = python3.withPackages (ps: with ps; [ pyyaml cryptography ]);
in
stdenv.mkDerivation {
  pname = "hermes-webui";
  inherit version src;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/hermes-webui
    cp -r api static server.py bootstrap.py ctl.sh $out/share/hermes-webui/
    cp -r --dereference scripts $out/share/hermes-webui/ 2>/dev/null || true

    makeWrapper ${pythonEnv}/bin/python3 $out/bin/hermes-webui \
      --add-flags "$out/share/hermes-webui/server.py" \
      --chdir "$out/share/hermes-webui"

    runHook postInstall
  '';

  meta = {
    description = "Web interface for Hermes Agent";
    homepage = "https://github.com/nesquena/hermes-webui";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "hermes-webui";
  };
}