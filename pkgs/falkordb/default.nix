{
  lib,
  symlinkJoin,
  callPackage,
}:
symlinkJoin {
  name = "falkordb-4.20.4";
  paths = [
    (callPackage ./module.nix {})
    (callPackage ./browser.nix {})
  ];

  meta = {
    description = "FalkorDB graph database with browser UI";
    longDescription = ''
      FalkorDB is a graph database built on top of Redis. This combined
      package includes the Redis module (lib/falkordb.so) and the web
      browser UI (bin/falkordb-browser).
    '';
    homepage = "https://www.falkordb.com";
    license = lib.licenses.sspl;
    platforms = lib.platforms.linux;
  };
}