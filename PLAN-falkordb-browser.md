# Plan: Add FalkorDB Browser (Web Server) to @pkgs/falkordb

## Context

The FalkorDB project ships a browser-based UI (`falkordb-browser`) alongside the Redis module. The upstream Docker image (`falkordb/falkordb`) bundles both. Currently `pkgs/falkordb/` only has the `.so` Redis module and Python client. The user wants the browser included.

**Source**: `FalkorDB/falkordb-browser` v2.5.2 — Next.js 16 app with `output: 'standalone'`.

**Key finding**: GitHub releases have **no prebuilt assets** (all releases have empty `assets: []`). The only prebuilt distribution is the Docker image `falkordb/falkordb-browser`. We will build from source using `buildNpmPackage` — this is the only practical path without pulling Docker images.

**Existing infrastructure**: A NixOS service module already exists at `modules/services/falkordb.nix` that configures `services.redis.servers.falkordb` with the `.so` module loaded.

## Approach

### Package restructuring

Current structure:
```
pkgs/falkordb/
├── default.nix       # .so Redis module only (pname=falkordb)
└── python-client.nix # separate
```

New structure:
```
pkgs/falkordb/
├── default.nix        # combined: .so module + browser (pname=falkordb)
├── module.nix         # .so Redis module derivation (extracted from default.nix)
├── browser.nix        # browser web server derivation (new)
└── python-client.nix  # unchanged
```

`default.nix` becomes a combined package that wraps both `module.nix` and `browser.nix`, similar to how the Docker image bundles them. Outputs:
- `lib/falkordb.so` — the Redis module
- `share/falkordb-browser/` — the standalone Next.js build
- `bin/falkordb-browser` — wrapper script to run `node server.js`

### Browser derivation (`browser.nix`)

Use `buildNpmPackage` to build from source:
- Fetch source from `FalkorDB/falkordb-browser` tag `v2.5.2`
- Node.js ≥ 24 required (`nodejs_24`)
- Build: `next build --webpack` (the webpack flag is in the package.json build script)
- Install: copy `.next/standalone`, `.next/static`, and `public` to output
- Wrapper: `falkordb-browser` script that runs `node $out/share/falkordb-browser/server.js`

### NixOS service module

Extend `modules/services/falkordb.nix` to add an optional browser service:
- `services.falkordb.browser.enable` (default false)
- Systemd service that runs the browser on port 3000
- Depends on the redis-falkordb service being up
- Configurable environment variables (NEXTAUTH_URL, CSV_STORAGE, etc.)

## Files to modify

| File | Action | Description |
|------|--------|-------------|
| `pkgs/falkordb/module.nix` | **new** | Extract the .so derivation from current default.nix |
| `pkgs/falkordb/browser.nix` | **new** | buildNpmPackage for the Next.js browser |
| `pkgs/falkordb/default.nix` | **rewrite** | Combined package wrapping module + browser |
| `modules/packages.nix` | **edit** | Add falkordb-browser (or update falkordb entry) |
| `modules/services/falkordb.nix` | **edit** | Add optional browser systemd service |

## Reuse

- `buildNpmPackage` — already used for `dirac`, `actual-cli`, `gondolin`
- `fetchFromGitHub` — used throughout the repo
- `nodejs_24` — available in nixpkgs
- `makeWrapper` — used in several packages
- Existing `modules/services/falkordb.nix` — already sets up redis + falkordb.so, we extend it

## Steps

- [ ] 1. Create `pkgs/falkordb/module.nix` by extracting the `.so` derivation from current `default.nix`
- [ ] 2. Create `pkgs/falkordb/browser.nix` using `buildNpmPackage`:
  - Source: `FalkorDB/falkordb-browser` tag `v2.5.2`
  - Use `nodejs_24`, `npmBuildScript = "build"`
  - Install `.next/standalone`, `.next/static`, `public` to output
  - Create `bin/falkordb-browser` wrapper
  - Compute `npmDepsHash`
- [ ] 3. Rewrite `pkgs/falkordb/default.nix` as combined package:
  - Calls `./module.nix` for `lib/falkordb.so`
  - Calls `./browser.nix` for the browser
  - Symlinks both into a single output
- [ ] 4. Update `modules/packages.nix` (may need package name adjustment)
- [ ] 5. Extend `modules/services/falkordb.nix` with optional `services.falkordb.browser` submodule
- [ ] 6. Build and verify: `nix build '.#falkordb'`

## Verification

- `nix build '.#falkordb'` succeeds (or `.#falkordb-browser` if kept separate)
- Output contains `lib/falkordb.so` and `bin/falkordb-browser`
- `nix flake check` passes
- Browser service starts and listens on port 3000 when `services.falkordb.browser.enable = true`