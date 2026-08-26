{
  stdenv,
  lib,
  fetchFromGitHub,
  nodejs,
  yarn-berry,
  makeWrapper,
  python3,
  writableTmpDirAsHomeHook,
}: let
  version = "2.8.0";

  src = fetchFromGitHub {
    owner = "twentyhq";
    repo = "twenty";
    rev = "v${version}";
    hash = "sha256-22NNIEWETJ1DKzTWtNLNS/dmtuTNTIQqsTnouGPCemc=";
  };

  treeversePatch = ./treeverse-hash.patch;
  missingHashes = ./missing-hashes.json;

  offlineCache = yarn-berry.passthru.fetchYarnBerryDeps {
    inherit src missingHashes;
    patches = [treeversePatch];
    hash = "sha256-QawIla4HEsanI3udnHj0FKe8F+6c+xKTS+tjc7JX6nA=";
  };
in
  stdenv.mkDerivation {
    pname = "twenty";
    inherit version src;

    patches = [treeversePatch];
    postPatch = ''
      echo "=== Remove unneeded workspaces ==="
      python3 -c "
import json
with open('package.json') as f:
    data = json.load(f)
keep = [
    'packages/twenty-front',
    'packages/twenty-server',
    'packages/twenty-emails',
    'packages/twenty-ui',
    'packages/twenty-utils',
    'packages/twenty-shared',
    'packages/twenty-sdk',
    'packages/twenty-front-component-renderer',
    'packages/twenty-client-sdk',
]
data['workspaces']['packages'] = [p for p in data['workspaces']['packages'] if p in keep]
with open('package.json', 'w') as f:
    json.dump(data, f, indent=2)
print('Kept workspaces:', data['workspaces']['packages'])
"

      echo "=== Remove dev deps that need registry cache ==="
      python3 -c "
import json
deps_to_remove = {
    'danger', 'danger-plugin-todos',
    '@genql/cli', '@genql/runtime',
    '@typescript/native-preview',
    'esbuild',
    '@oxlint/plugins',
}
affected = [
    'packages/twenty-utils/package.json',
    'packages/twenty-sdk/package.json',
    'packages/twenty-client-sdk/package.json',
    'packages/twenty-emails/package.json',
    'packages/twenty-front-component-renderer/package.json',
    'packages/twenty-shared/package.json',
    'packages/twenty-server/package.json',
    'packages/twenty-ui/package.json',
    'packages/twenty-front/package.json',
]
for pkg_json in affected:
    with open(pkg_json) as f:
        data = json.load(f)
    for key in ['dependencies', 'devDependencies', 'peerDependencies']:
        if key in data:
            data[key] = {k: v for k, v in data[key].items() if k not in deps_to_remove}
    with open(pkg_json, 'w') as f:
        json.dump(data, f, indent=2)
    print('Cleaned deps from', pkg_json)
"

      echo "=== Add missing esbuild lockfile entries ==="
      cat > /tmp/patch-lockfile.py << 'PYEOF'
import re

with open('yarn.lock') as f:
    content = f.read()

versions = {
    '0.25.8': '0.25.4',
    '0.27.7': '0.27.3',
}

for new_ver, src_ver in versions.items():
    exact = f'"esbuild@npm:{new_ver}":'
    if exact in content:
        print(f'esbuild {new_ver} already in lockfile')
        continue

    src_entry = f'"esbuild@npm:{src_ver}":'
    start_idx = content.index(src_entry)
    rest = content[start_idx:]
    end_m = re.search(r'\n\n(?=")', rest)
    if not end_m:
        print(f'Could not find end of esbuild {src_ver} entry')
        continue
    entry = rest[:end_m.start()]

    new_entry = entry.replace(src_ver, new_ver)
    new_entry = f'{exact}{new_entry[len(src_entry):]}\n'

    content = content[:start_idx] + new_entry + content[start_idx:]
    print(f'Added esbuild {new_ver} entry (from {src_ver})')

with open('yarn.lock', 'w') as f:
    f.write(content)
PYEOF
      python3 /tmp/patch-lockfile.py

      echo "=== Patch shebangs (pre-build) ==="
      patchShebangs scripts/ 2>/dev/null || true
    '';
    nativeBuildInputs = [
      nodejs
      yarn-berry
      makeWrapper
      python3
      writableTmpDirAsHomeHook
    ];

    dontYarnBerryInstallDeps = true;

    preConfigure = ''
      export HOME=$(mktemp -d)
      export npm_config_nodedir="${lib.getDev nodejs}"
      export npm_config_node_gyp="${nodejs}/lib/node_modules/npm/node_modules/node-gyp/bin/node-gyp.js"

      # Add offline-mode settings to the existing .yarnrc.yml
      # (keep bundled yarnPath and other project settings)
      cat >> .yarnrc.yml << 'YARNCFG'
enableOfflineMode: true
enableStrictSsl: false
enableScripts: true
npmMinimalAgeGate: 0
httpRetry: 0
approvedGitRepositories:
  - "**"
logFilters:
  - code: "YN0080"
    level: "warning"
  - code: "YN0001"
    level: "warning"
YARNCFG

      echo "=== .yarnrc.yml content ==="
      cat .yarnrc.yml

      rm -rf .yarn/cache
      mkdir -p .yarn
      cp -r --reflink=auto ${offlineCache}/cache ./.yarn/cache
      chmod u+w -R ./.yarn/cache
      [ -d ${offlineCache}/checkouts ] && cp -r --reflink=auto ${offlineCache}/checkouts ./.yarn/checkouts
      [ -d ${offlineCache}/checkouts ] && chmod u+w -R ./.yarn/checkouts

      export YARN_ENABLE_GLOBAL_CACHE=false
      export YARN_ENABLE_TELEMETRY=false
    '';

    configurePhase = ''
          runHook preConfigure

          # Use the nixpkgs yarn-berry-offline wrapper (handles offline + config validation)
          yarnPkg="${yarn-berry.passthru.yarn-berry-offline}/bin/yarn"

          echo "=== Syncing lockfile with modified package.json ==="
          YARN_IGNORE_PATH=1 $yarnPkg install --mode=update-lockfile --inline-builds 2>&1 || true

          echo "=== Running offline yarn install ==="
          YARN_IGNORE_PATH=1 $yarnPkg install --immutable --mode=skip-build --inline-builds 2>&1

          echo
          echo "=== Check if node_modules exists ==="
          if [ -d node_modules ]; then echo "node_modules OK"; else echo "node_modules MISSING"; fi

          echo "=== Patch shebangs ==="
          patchShebangs node_modules 2>/dev/null || true
          runHook postConfigure
        '';

    env.NODE_OPTIONS = "--max-old-space-size=8192";

    buildPhase = ''
      runHook preBuild
      export HOME=$(mktemp -d)

      # Generate barrels
      echo "=== Generate barrels ==="
      for pkg in twenty-shared twenty-ui; do
        if [ -f "packages/$pkg/scripts/generateBarrels.ts" ]; then
          npx tsx "packages/$pkg/scripts/generateBarrels.ts" || true
        fi
      done

      # Build packages in dependency order
      for pkg in twenty-shared twenty-ui twenty-client-sdk twenty-emails twenty-sdk twenty-front-component-renderer; do
        echo "=== Building $pkg ==="
        cd "packages/$pkg"
        npx vite build 2>/dev/null || true
        if [ -f tsconfig.lib.json ] && command -v tsgo &>/dev/null; then
          npx tsgo -p tsconfig.lib.json --declaration --emitDeclarationOnly --noEmit false --outDir dist --rootDir src 2>/dev/null || true
          npx tsc-alias -p tsconfig.lib.json --outDir dist 2>/dev/null || true
        fi
        cd "$OLDPWD"
      done

      # Build twenty-server
      echo "=== Building twenty-server ==="
      cd packages/twenty-server
      npx nest build || true
      cd "$OLDPWD"

      # Build twenty-front
      echo "=== Building twenty-front ==="
      cd packages/twenty-front
      npx vite build 2>/dev/null || echo "twenty-front build skipped"
      cd "$OLDPWD"

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/twenty
      cp -r packages/twenty-server/dist $out/share/twenty/dist
      cp packages/twenty-server/package.json $out/share/twenty/package.json

      for pkg in twenty-shared twenty-emails twenty-client-sdk; do
        mkdir -p $out/share/twenty/node_modules/$pkg
        cp -r packages/$pkg/dist $out/share/twenty/node_modules/$pkg/dist
        cp packages/$pkg/package.json $out/share/twenty/node_modules/$pkg/
      done

      cp -rL node_modules $out/share/twenty/node_modules
      cp package.json yarn.lock tsconfig.base.json nx.json $out/share/twenty/

      mkdir -p $out/bin
      makeWrapper ${lib.getExe nodejs} $out/bin/twenty-server \
        --add-flags "$out/share/twenty/dist/main" \
        --chdir "$out/share/twenty" --set NODE_ENV production
      makeWrapper ${lib.getExe nodejs} $out/bin/twenty-worker \
        --add-flags "$out/share/twenty/dist/queue-worker/queue-worker" \
        --chdir "$out/share/twenty" --set NODE_ENV production
      makeWrapper ${lib.getExe nodejs} $out/bin/twenty-command \
        --add-flags "$out/share/twenty/dist/command/command" \
        --chdir "$out/share/twenty" --set NODE_ENV production

      runHook postInstall
    '';

    meta = {
      description = "Twenty CRM - Modern open-source CRM";
      homepage = "https://twenty.com";
      license = lib.licenses.agpl3Only;
      platforms = lib.platforms.linux;
      mainProgram = "twenty-server";
    };
  }
