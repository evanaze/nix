{
  stdenvNoCC,
  lib,
  fetchFromGitHub,
  python3,
  makeWrapper,
  tmux,
  openssh,
  git,
  curl,
  nodejs,
}:
let
  version = "0-unstable-2026-06-15";

  src = fetchFromGitHub {
    owner = "pewdiepie-archdaemon";
    repo = "odysseus";
    rev = "c41caac438473b486bf2feb7c9566d8b2c7da707";
    hash = "sha256-mG1Q/mMlSI61osbs7AQ8/cquNQg/AQ/e+CWkBo6qmn0=";
  };

  pythonEnv = python3.withPackages (ps:
    with ps;
      [
        fastapi
        uvicorn
        python-multipart
        python-dotenv
        httpx
        pydantic
        pydantic-settings
        sqlalchemy
        pypdf
        beautifulsoup4
        charset-normalizer
        numpy
        chromadb
        fastembed
        youtube-transcript-api
        markdown
        nh3
        icalendar
        python-dateutil
        caldav
        cryptography
        bcrypt
        mcp
        pyotp
        qrcode
        croniter
        httpx2
      ]
      ++ qrcode.optional-dependencies.pil);

  runtimePath = lib.makeBinPath [
    tmux
    openssh
    git
    curl
    nodejs
  ];
in
stdenvNoCC.mkDerivation {
  pname = "odysseus";
  inherit version src;

  nativeBuildInputs = [makeWrapper];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/odysseus $out/bin
    cp -r . $out/share/odysseus/

    makeWrapper ${pythonEnv}/bin/python $out/bin/odysseus \
      --add-flags "-m uvicorn app:app --app-dir $out/share/odysseus" \
      --prefix PATH : ${runtimePath}

    makeWrapper ${pythonEnv}/bin/python $out/bin/odysseus-setup \
      --add-flags "$out/share/odysseus/setup.py" \
      --prefix PATH : ${runtimePath}

    runHook postInstall
  '';

  meta = {
    description = "Self-hosted AI workspace for chat, agents, research, documents, email, notes, calendar, and local model workflows";
    homepage = "https://github.com/pewdiepie-archdaemon/odysseus";
    license = lib.licenses.agpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "odysseus";
  };
}
