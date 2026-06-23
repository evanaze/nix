{
  stdenv,
  lib,
  fetchurl,
  bun,
  nodejs,
  makeWrapper,
}:

let
  version = "4.13.0";

  fetchNpmTarball = name: hash:
    fetchurl {
      url = "https://registry.npmjs.org/${name}/-/${name}-${version}.tgz";
      inherit hash;
    };

  platformPackages = [
    {
      name = "oh-my-openagent-linux-x64";
      src = fetchNpmTarball "oh-my-openagent-linux-x64" "sha256-+gGpHhngylr+oesJ83GDfopLxi8m80VrhVrkh9K8fvk=";
    }
    {
      name = "oh-my-openagent-linux-x64-baseline";
      src = fetchNpmTarball "oh-my-openagent-linux-x64-baseline" "sha256-HUTLCu5Sq4Y4QeN0aysNymH3zG0NPerfc5Xpfjh+Rng=";
    }
  ];
in
stdenv.mkDerivation {
  pname = "oh-my-openagent";
  inherit version;

  src = fetchNpmTarball "oh-my-openagent" "sha256-2cmMqLkHGZMyJK7rutUM3Om5cTJ9v11Iwb/X4sX0LC4=";

  nativeBuildInputs = [ makeWrapper ];

  sourceRoot = "package";

  postPatch = ''
    substituteInPlace bin/oh-my-opencode.js \
      --replace-fail 'const detectLibc = require("detect-libc");' '// detect-libc is omitted from this Nix package.' \
      --replace-fail 'return detectLibc.familySync();' 'return "glibc";'
  '';

  installPhase = ''
    runHook preInstall

    packageRoot=$out/share/node_modules/oh-my-openagent
    mkdir -p "$packageRoot" "$out/share/node_modules" "$out/bin"
    cp -r . "$packageRoot/"

    ${lib.concatMapStringsSep "\n" (pkg: ''
      tar -xzf ${pkg.src}
      mv package "$out/share/node_modules/${pkg.name}"
    '') platformPackages}

    makeWrapper ${lib.getExe nodejs} $out/bin/oh-my-openagent \
      --add-flags "$packageRoot/bin/oh-my-opencode.js" \
      --set-default BUN_BINARY ${lib.getExe bun}

    ln -s oh-my-openagent $out/bin/oh-my-opencode
    ln -s oh-my-openagent $out/bin/omo
    ln -s oh-my-openagent $out/bin/lazycodex
    ln -s oh-my-openagent $out/bin/lazycodex-ai

    runHook postInstall
  '';

  meta = {
    description = "Batteries-included OpenCode plugin with multi-model orchestration";
    homepage = "https://github.com/code-yeongyu/oh-my-openagent";
    platforms = [ "x86_64-linux" ];
    mainProgram = "oh-my-openagent";
  };
}
