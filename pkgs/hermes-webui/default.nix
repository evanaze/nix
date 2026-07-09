{
  stdenv,
  lib,
  fetchFromGitHub,
  python3,
  makeWrapper,
  hermes-agent ? null,
}:
let
  version = "0.52.0";

  src = fetchFromGitHub {
    owner = "nesquena";
    repo = "hermes-webui";
    rev = "v${version}";
    hash = "sha256-ngCivz9D+WrDbVdrPUnNC5KP9NBIjSezAPJpzFPBqyw=";
  };

  pythonEnv =
    if hermes-agent != null && hermes-agent ? hermesVenv then
      hermes-agent.hermesVenv
    else
      python3.withPackages (
        ps: with ps; [
          pyyaml
          cryptography
        ]
      );
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
