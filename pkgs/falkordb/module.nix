{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  openssl,
}: let
  version = "4.20.4";
in
  stdenv.mkDerivation {
    pname = "falkordb";
    inherit version;

    src = fetchurl {
      url = "https://github.com/FalkorDB/FalkorDB/releases/download/v${version}/falkordb-x64.so";
      hash = "sha256-geprmJ3C/Uya2QXiRgGLIgsC8OQMQGJV+dpHaMFoRVU=";
    };

    dontUnpack = true;

    nativeBuildInputs = lib.optionals stdenv.isLinux [autoPatchelfHook];

    # autoPatchelfHook scans for needed libs; add more here if FalkorDB
    # pulls in extra shared libraries on Linux.
    buildInputs =
      lib.optionals stdenv.isLinux [openssl stdenv.cc.cc.lib]
      ++ lib.optionals stdenv.isDarwin [openssl];

    installPhase = ''
      runHook preInstall
      mkdir -p $out/lib
      cp $src $out/lib/falkordb.so
      chmod 755 $out/lib/falkordb.so
      runHook postInstall
    '';

    meta = {
      description = "FalkorDB graph database Redis module";
      longDescription = ''
        FalkorDB is a graph database built on top of Redis. It is loaded as a
        Redis module and exposes a Cypher-compatible graph query interface via
        the GRAPH.* command family.
      '';
      homepage = "https://www.falkordb.com";
      license = lib.licenses.sspl;
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
      platforms = lib.platforms.linux;
      maintainers = [];
    };
  }
