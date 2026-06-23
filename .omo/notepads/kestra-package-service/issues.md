# Issues

- No `LoadCredential` / `SetCredential` examples found in the repo; Kestra should not rely on a missing local precedent.
- No `RuntimeDirectory` examples found; use `StateDirectory` unless there is a strong reason to deviate.
- No `lib.mkOption` / `types.submodule` / `types.attrs*` option-definition examples were found in this pass; Kestra module option design will need to be repo-local and explicit.
- Avoid copying secret-templating `preStart` patterns from `modules/business/seaweedfs.nix` and `modules/services/donetick.nix`; they write secret-derived config at runtime via shell substitution and are fragile.
- Avoid root-run services that materialize secret config (`modules/business/seaweedfs.nix`) unless the unit truly must run as root.
- Avoid the trust-based local PostgreSQL setup in `modules/business/nocodb.nix` / `modules/business/twenty.nix` if Kestra needs passworded auth.
- `modules/services/odysseus.nix` is a cautionary example: disables `DynamicUser` and uses broad writable paths plus manual mkdir in `preStart`.
## 2026-06-21 external research issues: Kestra package/service

- Need confirm Kestra executable artifact URL and required Java 25 derivation attribute in current nixpkgs before implementing.
- Avoid generating final YAML with secret values via `pkgs.writeText`, `format.generate`, or `lib.generators.toYAML` if it embeds secret values; those write to `/nix/store`. Use runtime generation, `sops.templates`, `LoadCredential`, or secret file paths instead.
- If Kestra does not support `_FILE` environment variables or secret-file references for a setting, prefer a runtime-rendered config under `/run/kestra` with `0600` permissions and service ownership; do not interpolate secret values in Nix expressions.



## 2026-06-21 Kestra 1.3.22 uncertainties
- Datasource key spelling mismatch: official current docs use `driver-class-name`, but the v1.3.22 source docker-compose example uses `driverClassName`. Micronaut usually supports relaxed binding, but this was not runtime-tested because no Java runtime is available in the research environment. Prefer docs spelling for new NixOS config, or test with `kestra configs properties` during implementation.
- Default config path mismatch: standalone docs mention `${HOME}/.kestra/config.yaml`, while CLI docs and v1.3.22 source default to `${HOME}/.kestra/config.yml`; NixOS service should pass an explicit absolute `--config` path.
- Java runtime: official standalone docs say JVM 21+ and v1.3.22 bytecode inspection of `io/kestra/cli/App.class` showed Java class major 65 (Java 21), but the official Dockerfile uses JRE 25. Packaging can likely use Java 21+, though Java 25 matches the official image/build toolchain.
- OpenViking had no indexed Kestra repo available under `viking://resources/`; research used official docs, cloned source, release API, and release assets instead.
## 2026-06-21 15:34:26 MDT
 - `nix-instantiate` evaluation of the module without full NixOS module context was noisy and stack-overflowed when trying to force evaluation of options/config simultaneously; no source error found, and `nix-instantiate --parse` plus diagnostics are clean.
 - Current validation is currently limited to parse/eval checks only because a full host eval may depend on unrelated host/package state.

## 2026-06-21 15:44:49 MDT — Kestra Task 4
- Initial `modules/services/kestra.nix` rewrite introduced malformed Nix quoting; this was fixed by rewriting the `_secret` token line and adding missing `runtime_path` binding used by Python preStart replacement script.
- `sops --set` path required explicit subcommand/arguments and behaved less predictably on encrypted input, so secret insertion was done via:
  `sops decrypt -> yq update keys -> sops encrypt --age ...`.
- Had to use absolute `/run/current-system/sw/bin/sops` with `SOPS_AGE_KEY_FILE` for deterministic behavior; plain `sops` invocation in this environment produced parser-like noise in shells.
- While this task did not yet enable service on `jupiter`, ensure a follow-up wiring task sets `services.kestra.enable = true` only where intended and validates `micronaut.server.host` remains `127.0.0.1`.
