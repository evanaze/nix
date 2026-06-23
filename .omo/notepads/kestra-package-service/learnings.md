# Learnings

- Use `lib.mkOverride 10` + `lib.mkAfter` for PostgreSQL auth appends (`modules/business/ducklake.nix`) instead of replacing the whole auth file (`modules/business/postgres.nix`).
- Prefer `EnvironmentFile` / `environmentFile` / `environmentFiles` for secret-backed env injection (`services/actual.nix`, `services/searx.nix`, `services/hermes-agent.nix`).
- Use `StateDirectory` + `ReadWritePaths` for mutable state; strongest local template is `modules/business/firecrawl.nix`.
- Package wrappers in this repo are usually thin `makeWrapper`/`wrapProgram` shims around a copied runtime tree (`pkgs/twenty`, `pkgs/odysseus`, `pkgs/hermes-webui`, `pkgs/oh-my-opencode`).
## 2026-06-21 external research: Kestra JAR package/service patterns

- Nixpkgs Java binary packages commonly use `fetchurl` with SRI `hash = "sha256-..."`, `dontUnpack = true`, copy the JAR into `$out/share/java`, and wrap `${jre}/bin/java` with `makeWrapper --add-flags "-jar ..."`; example: nixpkgs `pkgs/by-name/jr/jreleaser-cli/package.nix` at 80475a8c5ba1122a80be7daf8691f64daba99583 lines 12-25.
- Multiple Java entrypoints can be exposed from one JAR via `makeWrapper ${jre}/bin/java ... --add-flags "-cp ... MainClass"`; example: nixpkgs `pkgs/by-name/tl/tlaplus18/package.nix` lines 13-34.
- For YAML generated from Nix attrs, prefer `pkgs.formats.yaml { }` with `format.type`/`format.generate` in NixOS modules; example: `nixos/modules/services/networking/headplane.nix` lines 17, 33, 44-49. `lib.generators.toYAML { }` is just `toJSON` because YAML 1.2 is a JSON superset (`lib/generators.nix` lines 925-941).
- Safest secret handling pattern: do not put plaintext secrets in Nix attrs/store. Use file paths (`config.sops.secrets.<name>.path`) or `_secret = /path/to/secret` style runtime substitution. Nixpkgs `utils.genJqSecretsReplacement` documents replacing `{ _secret = "/path/to/secret" }` at service preStart time (`nixos/lib/utils.nix` lines 267-343); Recyclarr/Perses use it with `LoadCredential` (`recyclarr.nix` lines 14-16, 101-113; `perses.nix` lines 23-26, 78-99).
- If the app needs one complete config file containing secrets, `sops.templates` renders under `/run/secrets/rendered` with mode/owner controls (`sops-nix modules/sops/templates/default.nix` lines 31-39, 47-90) and replaces `config.sops.placeholder.*` at activation (`README.md` lines 1018-1057).
- For non-secret generated runtime config, copying/generating into `/run/<service>` in `preStart` with `RuntimeDirectory`/`StateDirectory` is a nixpkgs pattern; Actual generates `/run/actual/config.json` in preStart and sets `RuntimeDirectory`/`StateDirectory` (`actual.nix` lines 114-124).
- Hashes: prefer new `hash = "sha256-..."` SRI. `fetchurl` still accepts legacy `sha256 = ...`, but its implementation labels `hash` as SRI and `sha256` as legacy (`pkgs/build-support/fetchurl/default.nix` lines 165-173). Convert raw hex/base32/base64 with `nix hash convert --hash-algo sha256 --to sri <hash>` or `nix-hash --type sha256 --to-sri <hash>` per Nix manual.



## 2026-06-21 Kestra 1.3.22 packaging/service research
- Official standalone docs say the executable JAR runs on JVM 21+, supports `server standalone`, accepts `--config`/`-c`, and has no bundled plugins; use `--plugins`/`-p` or `KESTRA_PLUGINS_PATH` for a plugin directory. Docs source: https://github.com/kestra-io/docs/blob/6a6c4e1a69abe98afd2392055155fd87faf8b1dc/src/contents/docs/02.installation/12.standalone-server/index.md#L13-L29 and CLI docs: https://github.com/kestra-io/docs/blob/6a6c4e1a69abe98afd2392055155fd87faf8b1dc/src/contents/docs/kestra-cli/kestra-server/index.md#L43-L50
- `v1.3.22` GitHub release asset is pinned at `https://github.com/kestra-io/kestra/releases/download/v1.3.22/kestra-1.3.22`; official `checksums_sha256.txt` contains `b04aad0a7e269cfd9fad5f11b2489264b4fd53d20fe5b125dadfebcd7b6b33cd  kestra-1.3.22`. Release API also reports asset digest `sha256:b04aad...b33cd`.
- PostgreSQL config per current official docs uses `datasources.postgres.driver-class-name: org.postgresql.Driver`, plus `kestra.repository.type: postgres` and `kestra.queue.type: postgres`. Docs: https://github.com/kestra-io/docs/blob/6a6c4e1a69abe98afd2392055155fd87faf8b1dc/src/contents/docs/configuration/02.runtime-and-storage/index.md#L41-L70
- Kestra 1.3.22 source examples still use camelCase `driverClassName` in `docker-compose.yml`; current docs use kebab-case `driver-class-name`. Source example: https://github.com/kestra-io/kestra/blob/cb574545c42ead97d2adb42e22a4f65a54873a17/docker-compose.yml#L37-L42
- Local storage config is `kestra.storage.type: local` with `kestra.storage.local.base-path`; official docs say local storage works for standalone deployments with a persistent volume. Docs: https://github.com/kestra-io/docs/blob/6a6c4e1a69abe98afd2392055155fd87faf8b1dc/src/contents/docs/configuration/02.runtime-and-storage/index.md#L220-L240
- Localhost binding: Kestra docs document Micronaut-backed server settings and `micronaut.server.port`; Micronaut official docs say `micronaut.server.host` restricts binding to localhost and `micronaut.server.netty.listeners.*.host` is available for listener-specific binding. Kestra docs: https://github.com/kestra-io/docs/blob/6a6c4e1a69abe98afd2392055155fd87faf8b1dc/src/contents/docs/configuration/03.observability-and-networking/index.md#L168-L186
- systemd template from official docs uses `Type=simple`, `Restart=always`, `RestartSec=5`, `KillMode=mixed`, `TimeoutStopSec=150`, and `SuccessExitStatus=143`. Docs: https://github.com/kestra-io/docs/blob/6a6c4e1a69abe98afd2392055155fd87faf8b1dc/src/contents/docs/02.installation/12.standalone-server/index.md#L60-L78
- Java version nuance: standalone docs say JVM 21+; v1.3.22 source builds with Java toolchain 25 but `options.release = 21`, and Dockerfile uses `eclipse-temurin:25-jre-jammy`. Source: https://github.com/kestra-io/kestra/blob/cb574545c42ead97d2adb42e22a4f65a54873a17/build.gradle#L62-L70 and https://github.com/kestra-io/kestra/blob/cb574545c42ead97d2adb42e22a4f65a54873a17/Dockerfile#L1-L3

## 2026-06-21 15:33:10 MDT — Kestra package implementation

- Implemented `pkgs/kestra/default.nix` for pinned standalone JAR release `v1.3.22` using exact URL `https://github.com/kestra-io/kestra/releases/download/v${version}/kestra-${version}` and `fetchurl` with `dontUnpack = true`.
- Wrapper uses Java 25 runtime via `javaPackages.compiler.temurin-bin.jre-25` and `makeWrapper` to execute `${jre}/bin/java --add-flags "-jar" --add-flags "$out/share/java/kestra.jar"` as `bin/kestra`.
- Exposed package in `modules/packages.nix` with `kestra = pkgs.callPackage ../pkgs/kestra {};` per existing style.
- Verified raw SHA-256 hex `b04aad...b33cd` must be converted with `nix hash convert --hash-algo sha256 --from base16 --to sri <hex>` and currently used as `sha256-sEqtCn4mnP2frV8RskiSZLT9U9IP5bEl2t/rzXtrM80=` in-package.
## 2026-06-21 15:34:17 MDT
- Added reusable  with  option set (-
.
:
[
alias
autoload
bg
bindkey
break
builtin
bye
cd
chdir
command
compadd
comparguments
compcall
compctl
compdescribe
compfiles
compgroups
compquote
compset
comptags
comptry
compvalues
continue
declare
dirs
disable
disown
echo
echotc
echoti
emulate
enable
eval
exec
exit
export
false
fc
fg
float
functions
getln
getopts
hash
history
integer
jobs
kill
let
limit
local
log
logout
noglob
popd
print
printf
private
pushd
pushln
pwd
r
read
readonly
rehash
return
sched
set
setopt
shift
source
suspend
test
times
trap
true
ttyctl
type
typeset
ulimit
umask
unalias
unfunction
unhash
unlimit
unset
unsetopt
vared
wait
whence
where
which
zcompile
zformat
zle
zmodload
zparseopts
zregexparse
zstyle, , , , , , , ).
- Generated non-secret config via  into  (Nix store) and added  recursion that converts  leaves into placeholder tokens, then materializes final runtime YAML in  via inline Python replacement.
## 2026-06-21 15:34:21 MDT
- Added reusable modules/services/kestra.nix with services.kestra option set (enable, package, settings, user, group, stateDir, pluginPath, runtimeConfigFile).
- Generated non-secret config via pkgs.formats.yaml into a store template and added _secret-aware substitution recursion that replaces leaf _secret values with tokens, then materializes final runtime YAML in preStart via inline Python substitution.
- Service unit runs `kestra server standalone --config <runtime-config> --plugins <path>` and sets Type=simple, Restart=always, RestartSec=5, KillMode=mixed, TimeoutStopSec=150, SuccessExitStatus=143, StateDirectory=kestra.
- Exported module as flake.modules.nixos.servicesKestra; no host changes or enablement were made.
## 2026-06-21 15:34:43 MDT
- Corrective note: previous append operation accidentally leaked shell output; the effective intended takeaways are the entries immediately following this note and the four bullets above it in the `2026-06-21 15:34:21 MDT` block.
## 2026-06-21 15:35:13 MDT
 - Tightened plugin defaulting: `pluginPath = null` now resolves to `${stateDir}/plugins` in-module, so custom `stateDir` automatically scopes plugin dir.
 - Added `StateDirectoryMode = "0750"` while keeping required `StateDirectory = "kestra"`.

## 2026-06-21 15:44:49 MDT — Kestra Task 4 (Postgres + sops)
- Repaired `modules/services/kestra.nix` syntax after earlier edit glitch and completed PostgreSQL wiring under `config = mkIf cfg.enable`:
  - added DB init defaults/options (`databaseName`, `databaseUser`, `databaseHost`, `databasePort`).
  - added secret-backed settings options for `databasePasswordSecret`, `encryptionSecretKey`, `jdbcSecretKey`.
  - runtime config now substitutes `_secret` leaves via `substituteSecrets` and generates `/run/kestra/application.yaml` in `preStart` with token replacement.
- `services.postgresql` now extends existing config instead of replacing it:
  - `ensureDatabases`/`ensureUsers` for Kestra user + db.
  - `authentication = lib.mkOverride 10 (lib.mkAfter ...)` using localhost rules (`127.0.0.1/::1`).
- Added oneshot `systemd.services.kestra-db-init` (runs as postgres, uses `psql` and `SELECT format(... %L/%I)` with vars) and service ordering (`wants/requires/after` on postgres, sops, db-init) for Kestra service startup.
- Added Kestra secret declarations in module scope for:
  - `${cfg.databasePasswordSecret}` (owner service user, group postgres, mode 0640)
  - `${cfg.encryptionSecretKey}` (owner/group service, 0400)
  - `${cfg.jdbcSecretKey}` (owner/group service, 0400)
- Added encrypted entries in `secrets/secrets.yaml` for:
  - `kestra.db-password`, `kestra.encryption-secret-key`, `kestra.jdbc-secret-key` (generated non-plaintext values, re-encrypted with existing age recipients).
