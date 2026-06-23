# Kestra Package and NixOS Service

## Context

### Original Request
Create a package under `pkgs/` to install Kestra, using the standalone server guide at https://kestra.io/docs/installation/standalone-server. The package should create a NixOS service with `enable` and `settings` options, where `settings` renders into Kestra `config.yaml`.

### Interview Summary
**Key Discussions**:
- Target host: `jupiter`.
- Runtime mode: Kestra `server standalone`, not local/H2 mode.
- Database: provision a local PostgreSQL database/user for Kestra on `jupiter`.
- Secrets: integrate with sops-nix so sensitive values do not enter the Nix store.
- Version: pin Kestra `1.3.22` from GitHub release asset.
- Plugins: expose a plugin path option; do not package or auto-install plugins initially.
- Verification: use manual/Nix checks; do not add a NixOS VM test harness.

**Research Findings**:
- No existing `kestra` package was found in nixpkgs unstable.
- Kestra standalone docs: executable artifact runs as `kestra server local` or `kestra server standalone`; config can be supplied with `--config`; plugin directory can be supplied with `--plugins`; systemd guidance includes `Type=simple`, `Restart=always`, `RestartSec=5`, `KillMode=mixed`, `TimeoutStopSec=150`, and `SuccessExitStatus=143`.
- Kestra `1.3.22` release asset: `https://github.com/kestra-io/kestra/releases/download/v1.3.22/kestra-1.3.22`; observed SHA-256 hex: `b04aad0a7e269cfd9fad5f11b2489264b4fd53d20fe5b125dadfebcd7b6b33cd`.
- Kestra standalone page says JVM 21+, but Kestra 1.3 release docs indicate Java 25+; Nix unstable provides `javaPackages.compiler.temurin-bin.jre-25`.
- Package exposure pattern: `modules/packages.nix:2-13` exposes packages via `pkgs.callPackage ../pkgs/<name> {}`.
- Service module export pattern: existing modules under `modules/services/` expose public names such as `servicesSearx` and sometimes aggregate `services`.
- YAML/secret runtime pattern: `modules/services/donetick.nix:40-91` generates runtime YAML with sops secret substitution outside the Nix store.
- PostgreSQL/sops pattern: `modules/business/ducklake.nix:8-65` provisions local databases/users and applies sops-managed PostgreSQL passwords.

### Metis Review
**Identified Gaps** (addressed):
- Data path was unspecified: default to `/var/lib/kestra` via systemd `StateDirectory=kestra` for the initial service; do not use `/mnt/eye` unless later requested.
- Bind/exposure was unspecified: default to localhost-only and explicitly avoid Caddy/Tailscale/firewall exposure.
- Auth posture was unspecified: rely on localhost-only initial binding; do not add Kestra auth/SSO unless later requested.
- PostgreSQL auth method needed clarity: use local TCP password auth with sops-managed password, not peer-only auth.
- Plugin unset behavior needed clarity: create/use a managed empty plugin directory under Kestra state, expose an option to override.
- Secret leakage risk: final secret-containing config must be generated at runtime outside `/nix/store`.

---

## Work Objectives

### Core Objective
Add a reproducible Kestra standalone package and a repo-local NixOS service module that can run Kestra on `jupiter` with PostgreSQL persistence, sops-managed secrets, runtime-generated `config.yaml`, and Nix-based verification.

### Concrete Deliverables
- `pkgs/kestra/default.nix` package for Kestra `1.3.22`.
- `modules/packages.nix` exposes `kestra` as a flake package.
- `modules/services/kestra.nix` defines `services.kestra.enable`, `services.kestra.settings`, and supporting options for package, plugin path, data directory, runtime config path, and sops secret names.
- `modules/hosts.nix` wires Kestra into `jupiter` explicitly.
- PostgreSQL database/user provisioning for Kestra on `jupiter`.
- Sops secret declarations for Kestra DB password and encryption/JDBC secret keys.
- Runtime-generated Kestra config file outside `/nix/store`.

### Definition of Done
- [ ] `nix build .#kestra` succeeds.
- [ ] `nix build .#packages.x86_64-linux.kestra` succeeds.
- [ ] `nix build .#nixosConfigurations.jupiter.config.system.build.toplevel` succeeds.
- [ ] `nix flake check` succeeds, or unrelated pre-existing failures are documented with evidence.
- [ ] Generated systemd unit starts Kestra with `server standalone` and `--config` pointing outside `/nix/store`.
- [ ] Sensitive values are not embedded in package derivations, static Nix-generated files, or systemd unit text.
- [ ] No Caddy, Tailscale Serve, firewall, Docker socket, plugin packaging, or public exposure is added.

### Must Have
- Kestra package pinned to version `1.3.22` with fixed hash.
- Java 25 runtime available to Kestra wrapper/service.
- Service option namespace: `services.kestra`.
- `services.kestra.settings` rendered into Kestra YAML config.
- Runtime injection of sops-managed secrets into final config outside the Nix store.
- Local PostgreSQL database/user setup for Kestra.
- Dedicated non-root `kestra` user/group.

### Must NOT Have (Guardrails)
- Do not implement Kestra Enterprise/EE license handling.
- Do not package plugins or install plugins automatically.
- Do not mount Docker socket or add Docker executor support.
- Do not add Caddy, Tailscale Serve, DNS, public proxy, firewall opening, or LAN/public binding.
- Do not put DB passwords, encryption keys, JDBC secret keys, auth passwords, or final secret YAML in `/nix/store`.
- Do not replace unrelated PostgreSQL auth rules; append Kestra-specific rules minimally.
- Do not add a VM test harness.
- Do not broaden this into an upstream-quality generic nixpkgs module beyond this repo’s needs.

---

## Verification Strategy (MANDATORY)

### Test Decision
- **Infrastructure exists**: YES, but it is Nix build/check infrastructure rather than application tests.
- **User wants tests**: Manual/Nix checks.
- **Framework**: Nix builds, flake checks, host build, systemd/config inspection.

### Manual QA Only
Automated application tests and NixOS VM tests are out of scope. Verification must use concrete commands and generated artifact inspection.

**Evidence Required:**
- Build command outputs.
- Relevant snippets from generated systemd unit/config inspection.
- Confirmation that no secret values appear in store paths or static units.

---

## Task Flow

```text
Task 1 → Task 2 → Task 3 → Task 4 → Task 5 → Task 6
          ↘ Task 7 (verification after implementation)
```

## Parallelization

| Group | Tasks | Reason |
|-------|-------|--------|
| A | 2, 3 | Package work and module design can be developed independently after baseline inspection. |
| B | 4, 5 | Sops/PostgreSQL integration and host wiring depend on module option names from Task 3. |
| C | 6, 7 | Documentation/inspection and final checks happen after implementation. |

| Task | Depends On | Reason |
|------|------------|--------|
| 2 | 1 | Needs confirmed package exposure conventions. |
| 3 | 1 | Needs confirmed service module conventions. |
| 4 | 3 | Needs final Kestra module option names and config generation approach. |
| 5 | 3, 4 | Host wiring should enable the completed service/database/secrets design. |
| 6 | 2, 3, 4, 5 | Generated artifacts exist only after implementation. |
| 7 | 2, 3, 4, 5, 6 | Final verification validates all deliverables. |

---

## TODOs

> Implementation + verification = one task. Do not split tests into separate tasks.

- [x] 1. Confirm repo integration points before editing

  **What to do**:
  - Inspect current package exposure in `modules/packages.nix`.
  - Inspect current service module exports in `modules/services/*.nix`.
  - Inspect current `jupiter` host composition in `modules/hosts.nix`.
  - Inspect PostgreSQL and sops patterns before copying any approach.

  **Must NOT do**:
  - Do not edit files during this inspection step.
  - Do not assume aggregate `business` or `services` exports include everything without checking final evaluation behavior.

  **Parallelizable**: NO.

  **References**:
  - `modules/packages.nix:2-13` - Package exposure pattern using `pkgs.callPackage`.
  - `modules/hosts.nix:110-135` - Current `jupiter` module list.
  - `modules/services/searx.nix:63-67` - Example public service module export.
  - `modules/business/postgres.nix:7-27` - Existing PostgreSQL enablement/auth pattern.
  - `modules/business/ducklake.nix:8-65` - Existing sops-backed PostgreSQL password setup pattern.
  - `modules/services/donetick.nix:40-91` - Runtime config generation pattern.

  **Acceptance Criteria**:
  - [x] Executor notes exact insertion points for package exposure, service module export, host wiring, PostgreSQL setup, and sops declarations.
  - [x] Executor confirms whether inline host config in `modules/hosts.nix` is acceptable or whether a host-specific module should be used.

  **Manual Execution Verification**:
  - [x] Run no mutation commands in this step.
  - [x] Capture file/line references used for later edits.

  **Commit**: NO.

- [x] 2. Add reproducible Kestra standalone package

  **What to do**:
  - Create `pkgs/kestra/default.nix`.
  - Fetch `https://github.com/kestra-io/kestra/releases/download/v1.3.22/kestra-1.3.22` with fixed SHA-256.
  - Convert the observed hex checksum to the hash format required by the chosen Nix fetcher if needed.
  - Install executable as `$out/bin/kestra`.
  - Ensure Kestra runs with Java 25, preferably by wrapping with `javaPackages.compiler.temurin-bin.jre-25` in `PATH` or equivalent.
  - Add package exposure in `modules/packages.nix` as `kestra = pkgs.callPackage ../pkgs/kestra {};` following existing style.

  **Must NOT do**:
  - Do not fetch from `https://api.kestra.io/v1/versions/download`; it is not pinned/reproducible.
  - Do not use an unpinned latest URL.
  - Do not include plugins in the package.

  **Parallelizable**: YES, with Task 3 after Task 1.

  **References**:
  - `modules/packages.nix:2-13` - Exact package exposure style.
  - `pkgs/oh-my-opencode/default.nix` - Fetched artifact/wrapper package style.
  - `pkgs/hermes-webui/default.nix` - Wrapper-style package pattern.
  - Kestra standalone docs - Linux standalone executable command pattern.
  - Kestra GitHub release `v1.3.22` - Pinned source artifact and checksum.
  - Nix package search result - `javaPackages.compiler.temurin-bin.jre-25` exists for Java 25.

  **Acceptance Criteria**:
  - [x] `pkgs/kestra/default.nix` exists.
  - [x] `modules/packages.nix` exposes `kestra`.
  - [x] `nix build .#kestra` → PASS.
  - [x] `nix build .#packages.x86_64-linux.kestra` → PASS.
  - [x] Result contains executable `bin/kestra`.
  - [x] `result/bin/kestra --help` or equivalent non-mutating help/version command runs using Java 25.

  **Manual Execution Verification**:
  - [x] Command: `nix build .#kestra`.
  - [x] Command: `./result/bin/kestra --help`.
  - [x] Expected output contains Kestra CLI help/version text and exits successfully.

  **Commit**: NO.

- [x] 3. Add reusable `services.kestra` NixOS module

  **What to do**:
  - Create `modules/services/kestra.nix`.
  - Define options under `services.kestra`, including at minimum:
    - `enable`
    - `package`
    - `settings`
    - `user`
    - `group`
    - `stateDir` or equivalent path option defaulting to `/var/lib/kestra` via `StateDirectory=kestra`
    - `pluginPath`, defaulting to a managed plugin directory under Kestra state
    - secret option names or paths for DB password, Kestra encryption key, and JDBC secret key
  - Render non-secret `settings` using `lib.generators.toYAML` or a carefully equivalent YAML-generation approach.
  - Generate the final secret-containing `config.yaml` at service runtime outside `/nix/store`, e.g. under `/run/kestra/config.yaml` or a private runtime/state path.
  - Add a systemd service that runs `kestra server standalone --config <runtime-config>` and includes `--plugins <plugin-path>` only when configured/available.
  - Use `Type=simple`, `Restart=always`, `RestartSec=5`, `KillMode=mixed`, `TimeoutStopSec=150`, `SuccessExitStatus=143`, `WorkingDirectory`, `StateDirectory`, and non-root `User`/`Group`.
  - Ensure `HOME`, temp/config directories, storage directory, and plugin directory are writable by the Kestra user.
  - Export the module as `flake.modules.nixos.servicesKestra = module;`. Only add it to aggregate `services` if it remains disabled by default and cannot enable Kestra implicitly.

  **Must NOT do**:
  - Do not render secret values with `pkgs.writeText` or into any derivation output.
  - Do not add Caddy/Tailscale/firewall exposure.
  - Do not enable the service implicitly on non-`jupiter` hosts.
  - Do not copy unrelated settings from another service without adapting names/paths.

  **Parallelizable**: YES, with Task 2 after Task 1.

  **References**:
  - `modules/services/searx.nix:13-25` - Simple service settings option usage.
  - `modules/services/donetick.nix:40-91` - Runtime YAML generation with secret substitution pattern to improve.
  - `modules/services/donetick.nix:93-101` - Basic systemd service shape.
  - Kestra standalone docs - `--config`, `--plugins`, and systemd recommendations.
  - Noogle result: `lib.generators.toYAML` - Nix library function for YAML-compatible generation.

  **Acceptance Criteria**:
  - [x] `modules/services/kestra.nix` exists.
  - [x] `services.kestra.enable` defaults to disabled.
  - [x] `services.kestra.settings` exists and affects generated YAML.
  - [x] Final runtime config path is outside `/nix/store`.
  - [x] Systemd unit contains `server standalone` and `--config`.
  - [x] Systemd unit runs as dedicated non-root `kestra` user/group.
  - [x] Unit does not contain secret literal values.

  **Manual Execution Verification**:
  - [x] Command: `nix eval .#nixosConfigurations.jupiter.config.systemd.services.kestra.serviceConfig.User`.
  - [x] Expected output: `"kestra"` or the configured non-root user.
  - [x] Command: inspect generated unit through `nix eval` or build output.
  - [x] Expected: `ExecStart` includes `server standalone --config` and no secret values.

  **Commit**: NO.

- [ ] 4. Add PostgreSQL and sops integration for Kestra

  **What to do**:
  - Add sops secret declarations for at least:
    - `kestra/db-password`
    - `kestra/encryption-secret-key`
    - `kestra/jdbc-secret-key`
  - Ensure secret ownership/mode permits the Kestra service and PostgreSQL password-init step to read only what they need.
  - Add PostgreSQL `ensureDatabases = [ "kestra" ]` and `ensureUsers` entry for a `kestra` role with login and database ownership.
  - Add a oneshot password-init service ordered after `postgresql.service` and `sops-secrets.target`.
  - Safely apply the database password without unsafe shell/SQL interpolation; handle quotes/newlines robustly.
  - Append PostgreSQL auth rules minimally for Kestra localhost password auth; do not replace existing auth block.
  - Add Kestra settings for PostgreSQL datasource, repository, queue, storage, URL, and local storage path.
  - Generate final config at runtime by combining non-secret settings with sops secret file values.

  **Must NOT do**:
  - Do not write DB password, encryption key, or JDBC secret key into `/nix/store`.
  - Do not override existing PostgreSQL users/authentication wholesale.
  - Do not assume secret values already exist without documenting the required `sops secrets/secrets.yaml` entries.

  **Parallelizable**: NO, depends on Task 3.

  **References**:
  - `modules/business/postgres.nix:7-27` - Existing PostgreSQL enablement/auth baseline.
  - `modules/business/ducklake.nix:8-65` - Existing DB/user/password-init pattern.
  - `modules/services/donetick.nix:40-91` - Runtime secret substitution pattern.
  - `modules/services/searx.nix:11-15` - Sops environment file pattern.
  - Kestra configuration docs - PostgreSQL datasource, repository, queue, and local storage examples.

  **Acceptance Criteria**:
  - [ ] Kestra DB and user are declared in NixOS PostgreSQL config.
  - [ ] Password initialization waits for PostgreSQL and sops secrets.
  - [ ] Secret declarations exist and have appropriate owner/group/mode.
  - [ ] Final runtime `config.yaml` contains datasource and Kestra secret values only after service runtime generation.
  - [ ] No `kestra/db-password`, encryption key literal, or JDBC key literal appears in Nix store paths, package derivations, or static unit text.

  **Manual Execution Verification**:
  - [ ] Command: `nix build .#nixosConfigurations.jupiter.config.system.build.toplevel`.
  - [ ] Expected: build succeeds.
  - [ ] Command: inspect generated service scripts/unit for literal secret values.
  - [ ] Expected: only secret file paths appear, not secret contents.

  **Commit**: NO.

- [ ] 5. Wire Kestra into `jupiter`

  **What to do**:
  - Add `servicesKestra` to `jupiter` host composition or otherwise include the module explicitly for `jupiter`.
  - Enable `services.kestra.enable = true` for `jupiter`.
  - Configure `services.kestra.settings` for localhost-only standalone operation:
    - Bind/listen only on localhost where supported by Kestra config.
    - Set `kestra.repository.type = "postgres"`.
    - Set `kestra.queue.type = "postgres"`.
    - Set `kestra.storage.type = "local"` with base path under Kestra state.
    - Set datasource URL to local PostgreSQL on localhost.
  - Ensure the service depends on PostgreSQL, sops secrets, and the password-init step.
  - Do not add reverse proxy or public exposure.

  **Must NOT do**:
  - Do not enable Kestra on `earth` or `mars`.
  - Do not add Caddy/Tailscale Serve or firewall settings.
  - Do not bind Kestra to `0.0.0.0`.

  **Parallelizable**: NO, depends on Tasks 3 and 4.

  **References**:
  - `modules/hosts.nix:110-135` - `jupiter` module list.
  - `modules/services/glance.nix` and `modules/services/odysseus.nix` - Existing host-specific service patterns, but do not copy proxy/Tailscale exposure.
  - Kestra config docs - Runtime/storage and PostgreSQL settings.

  **Acceptance Criteria**:
  - [ ] `jupiter` imports/includes the Kestra module.
  - [ ] `services.kestra.enable = true` is set only for `jupiter`.
  - [ ] Kestra settings bind localhost-only.
  - [ ] No public exposure is added.
  - [ ] Host build for `jupiter` succeeds.

  **Manual Execution Verification**:
  - [ ] Command: `nix eval .#nixosConfigurations.jupiter.config.services.kestra.enable`.
  - [ ] Expected output: `true`.
  - [ ] Command: `nix build .#nixosConfigurations.jupiter.config.system.build.toplevel`.
  - [ ] Expected: build succeeds.

  **Commit**: NO.

- [ ] 6. Inspect generated artifacts for correctness and secret safety

  **What to do**:
  - Inspect generated systemd service for Kestra.
  - Inspect generated/preStart runtime config generation script.
  - Verify config path is outside `/nix/store`.
  - Verify no secret literal values are embedded in static outputs.
  - Verify plugin path behavior: managed directory exists or is created; no plugin installation is attempted.
  - Verify PostgreSQL password-init ordering and auth append behavior.

  **Must NOT do**:
  - Do not start/deploy the service unless explicitly moving into runtime verification later.
  - Do not print secret contents into logs or terminal output.

  **Parallelizable**: NO, depends on Tasks 2-5.

  **References**:
  - `modules/services/kestra.nix` - New service implementation.
  - `modules/business/ducklake.nix:16-35` - Ordering pattern for DB init.
  - Kestra systemd docs - Expected service behavior.

  **Acceptance Criteria**:
  - [ ] Systemd unit has `After`/`Requires` or equivalent dependencies for PostgreSQL, sops secrets, and password init.
  - [ ] Runtime config destination is not under `/nix/store`.
  - [ ] Static unit/script text contains secret file paths only, not secret contents.
  - [ ] Plugin path is configurable and no plugin install command is present.

  **Manual Execution Verification**:
  - [ ] Command: inspect `nix eval .#nixosConfigurations.jupiter.config.systemd.services.kestra` output or built unit.
  - [ ] Expected: service shape matches Kestra standalone requirements.
  - [ ] Command: search generated unit/script output for known secret placeholder names only.
  - [ ] Expected: no literal secret values.

  **Commit**: NO.

- [ ] 7. Run final Nix verification

  **What to do**:
  - Run package build checks.
  - Run `jupiter` system build.
  - Run `nix flake check`.
  - If `nix flake check` fails due to unrelated pre-existing checks, document the exact failure and still provide successful targeted Kestra package/host build evidence.

  **Must NOT do**:
  - Do not deploy with `nixos-rebuild switch` as part of this plan unless user explicitly starts runtime deployment later.
  - Do not commit unless separately requested.

  **Parallelizable**: NO, final validation.

  **References**:
  - `modules/checks.nix:6-53` - Existing flake checks.
  - `CLAUDE.md:20-41` - Documented build and deployment commands.
  - `modules/hosts.nix:110-135` - `jupiter` configuration target.

  **Acceptance Criteria**:
  - [ ] `nix build .#kestra` → PASS.
  - [ ] `nix build .#packages.x86_64-linux.kestra` → PASS.
  - [ ] `nix build .#nixosConfigurations.jupiter.config.system.build.toplevel` → PASS.
  - [ ] `nix flake check` → PASS, or unrelated failures documented with exact output and targeted checks passing.

  **Manual Execution Verification**:
  - [ ] Command: `nix build .#kestra`.
  - [ ] Command: `nix build .#packages.x86_64-linux.kestra`.
  - [ ] Command: `nix build .#nixosConfigurations.jupiter.config.system.build.toplevel`.
  - [ ] Command: `nix flake check`.

  **Commit**: NO.

---

## Commit Strategy

No commits are included in this plan because the user did not request committing. If requested later, use one atomic commit after all verification passes.

| After Task | Message | Files | Verification |
|------------|---------|-------|--------------|
| Final only, if requested | `feat(kestra): add package and service` | `pkgs/kestra/default.nix`, `modules/packages.nix`, `modules/services/kestra.nix`, `modules/hosts.nix`, sops-related changes | `nix build .#kestra`; `nix build .#nixosConfigurations.jupiter.config.system.build.toplevel`; `nix flake check` |

---

## Success Criteria

### Verification Commands
```bash
nix build .#kestra
nix build .#packages.x86_64-linux.kestra
nix build .#nixosConfigurations.jupiter.config.system.build.toplevel
nix flake check
```

### Final Checklist
- [ ] Kestra package exists and builds reproducibly.
- [ ] Kestra service module exists with `enable` and `settings`.
- [ ] `settings` contributes to generated Kestra `config.yaml`.
- [ ] Secret-containing final config is generated outside `/nix/store`.
- [ ] PostgreSQL database/user/password handling exists for Kestra.
- [ ] `jupiter` enables Kestra; `earth` and `mars` do not.
- [ ] Service uses Java 25 and runs as a non-root `kestra` user.
- [ ] No public exposure/proxy/firewall/Tailscale/Docker/plugin packaging was added.
- [ ] Nix verification commands pass or unrelated failures are documented.
