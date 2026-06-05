{ stdenv, lib, fetchFromGitHub, bun2nix, bun, nodejs, makeWrapper }:

let
  version = "0.0.39";

  src = fetchFromGitHub {
    owner = "caioricciuti";
    repo = "duck-ui";
    rev = "v${version}";
    hash = "sha256-GzRc+tX0kD7+/ofVSzsLi7xkcxwjZcGcvAWvF12Q97Q=";
  };

in
stdenv.mkDerivation {
  pname = "duck-ui";
  inherit version src;

  nativeBuildInputs = [
    bun
    bun2nix.hook
    makeWrapper
  ];

  bunDeps = bun2nix.fetchBunDeps {
    bunNix = ./bun.nix;
  };

  dontUseBunBuild = true;
  dontUseBunCheck = true;

  bunInstallFlags = [
    "--linker=hoisted"
  ];

  buildPhase = ''
    runHook preBuild
    bun run build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/duck-ui
    cp -r dist/* $out/share/duck-ui/
    cp inject-env.js serve.json $out/share/duck-ui/

    mkdir -p $out/share/duck-ui/bin
    cat > $out/share/duck-ui/bin/server.js << 'NODESCRIPT'
const fs = require("fs");
const path = require("path");
const http = require("http");

const distDir = process.env.DUCK_UI_DIST;
const port = parseInt(process.env.PORT || "5522", 10);

const indexHtmlPath = path.join(distDir, "index.html");
let indexHtmlContent = fs.readFileSync(indexHtmlPath, "utf8");

const envVars = {
  DUCK_UI_EXTERNAL_CONNECTION_NAME: process.env.DUCK_UI_EXTERNAL_CONNECTION_NAME || "",
  DUCK_UI_EXTERNAL_HOST: process.env.DUCK_UI_EXTERNAL_HOST || "",
  DUCK_UI_EXTERNAL_PORT: process.env.DUCK_UI_EXTERNAL_PORT || null,
  DUCK_UI_EXTERNAL_USER: process.env.DUCK_UI_EXTERNAL_USER || "",
  DUCK_UI_EXTERNAL_PASS: process.env.DUCK_UI_EXTERNAL_PASS || "",
  DUCK_UI_EXTERNAL_DATABASE_NAME: process.env.DUCK_UI_EXTERNAL_DATABASE_NAME || "",
  DUCK_UI_ALLOW_UNSIGNED_EXTENSIONS: process.env.DUCK_UI_ALLOW_UNSIGNED_EXTENSIONS === "true" || false,
  DUCK_UI_DUCKDB_WASM_USE_CDN: process.env.DUCK_UI_DUCKDB_WASM_USE_CDN === "true" || false,
  DUCK_UI_DUCKDB_WASM_BASE_URL: process.env.DUCK_UI_DUCKDB_WASM_BASE_URL || "",
};

indexHtmlContent = indexHtmlContent.replace("</head>", "<script>window.env = " + JSON.stringify(envVars) + ";</script></head>");
fs.writeFileSync(indexHtmlPath, indexHtmlContent);

const mimeTypes = {
  ".html": "text/html", ".js": "text/javascript", ".css": "text/css",
  ".json": "application/json", ".png": "image/png", ".jpg": "image/jpeg",
  ".svg": "image/svg+xml", ".ico": "image/x-icon", ".wasm": "application/wasm",
};

const server = http.createServer((req, res) => {
  let filePath = path.join(distDir, req.url === "/" ? "index.html" : req.url);
  const ext = path.extname(filePath);
  const contentType = mimeTypes[ext] || "application/octet-stream";

  res.setHeader("Cross-Origin-Opener-Policy", "same-origin");
  res.setHeader("Cross-Origin-Embedder-Policy", "credentialless");

  fs.readFile(filePath, (err, data) => {
    if (err) {
      res.writeHead(404);
      res.end("Not found");
    } else {
      res.writeHead(200, { "Content-Type": contentType });
      res.end(data);
    }
  });
});

server.listen(port, () => {
  console.log("Duck-UI running at http://localhost:" + port);
});
NODESCRIPT

    mkdir -p $out/bin
    makeWrapper ${lib.getExe nodejs} $out/bin/duck-ui \
      --add-flags "$out/share/duck-ui/bin/server.js" \
      --set DUCK_UI_DIST "$out/share/duck-ui"

    runHook postInstall
  '';

  meta = {
    description = "Modern web interface for DuckDB";
    homepage = "https://duckui.com";
    license = lib.licenses.isc;
    platforms = lib.platforms.linux;
    mainProgram = "duck-ui";
  };
}