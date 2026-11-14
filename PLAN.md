# Plan: Split terminal + nixvim configs into independent flakes

## Context

This flake currently keeps **everything** in one repo via `inputs.import-tree ./modules`. The
user wants the **terminal** config (zsh, ghostty, required fonts) and the **nixvim** config to live
as **separate flakes**, so they can later be extracted into their own repos. For now the flakes
exist inside this repo as flake-parts module flakes and are wired in as inputs.

Branch is `terminal-editor-flake`, which matches the intent.

## Current state (findings)

| Concern | File(s) | Notes |
|---|---|---|
| zsh (system + home-manager, aliases, prompt, plugins) | `modules/development/zsh.nix` | exposes `flake.modules.nixos.developmentZsh` + `development` |
| ghostty + zellij + `nvim` wrapper | `modules/development/editors.nix` | ghostty settings (Iosevka/Catppuccin), zellij, `nvim = makeNixvimWithModule` |
| nixvim module (plugins, keymaps, lsp, themes, …) | `modules/development/_nixvim/` | a nixvim-style module dir, passed to `makeNixvimWithModule {module = ./_nixvim}` |
| fonts (Iosevka) | `modules/desktop/fonts.nix` | `fonts.packages = [iosevka]`; only consumer is ghostty's `font-family = "Iosevka"` |
| dev module aggregator | `modules/development/default.nix` | sets `flake.modules.nixos.development` (systemPackages: bun, nixd, python313Packages.huggingface-hub) |
| hosts import modules via | `modules/hosts.nix` | `with inputs.self.modules.nixos; [ … development … ]` |

External inputs are consumed as `inputs.<name>.nixosModules.default` (older convention), while
internal modules use the newer `flake.modules.nixos.X` convention.

## Proposed layout

Two new flake-parts **module flakes** under `modules/`, each with its own `flake.nix` + `flake.lock`:

```
modules/
  terminal/
    flake.nix            # flake-parts module flake
    flake.lock
    modules/
      zsh.nix            # moved from development/zsh.nix
      ghostty.nix        # ghostty + zellij moved from development/editors.nix
      fonts.nix          # Iosevka moved from desktop/fonts.nix
      default.nix        # exposes flake.modules.nixos.terminal
  nixvim/
    flake.nix
    flake.lock
    modules/
      default.nix        # exposes flake.modules.nixos.nixvim
      _nixvim/           # moved from development/_nixvim/
```

Remaining `development/*` modules (airflow, docker, devenv, direnv, git, languages, mcp, nono,
nupd, opencode, writr, pi-coding-agent) stay in place; `development/default.nix` keeps its
`flake.modules.nixos.development` systemPackages.

## Resolved decisions

1. **zellij** → **included** in the terminal flake (ghostty + zellij live together).
2. **`nvim` wrapper** → **nixvim flake owns it.** The nixvim flake exposes a module that builds
   `nixvim'.makeNixvimWithModule { module = ./_nixvim }` and applies it to `programs.nvim`.
   The terminal flake no longer references nixvim.
3. **fonts** → **terminal flake owns Iosevka** as a nixos `fonts.packages` module; `desktop`
   drops it (Iosevka is only consumed by ghostty here).
4. **wiring** → parent uses flake-parts `finalInputs: baseInputs` mkFlake; hosts reference
   base modules via `finalInputs.self.modules.nixos` and sub-flakes via `finalInputs.<name>`.

## Latent bug discovered (intentional fix)

`editors.nix` currently puts the `makeNixvimWithModule` result into `home.packages` instead of
`programs.nvim`. A nixvim module is not a buildable package, so the nixvim config (treesitter,
keymaps, lsp, themes, … in `_nixvim/`) was **defined but not applied**. The split fixes this:
the nixvim flake sets `home-manager.users.${username}.programs.nvim = <wrapper>`.

> Verify after split that nixvim actually loads (e.g. `nvim --headless` or check `:checktime`/
> plugins). This is a behavior change, not just a move.

## Approach

- Each sub-flake is a **flake-parts module flake** exposing `flake.modules.nixos.<name>`, matching
  the repo's internal convention, so it can later be dropped into its own repo unchanged.
  Each sub-flake needs `flake-parts` (followed from the parent) plus its own `flake.lock`.
- Parent `flake.nix` declares `terminal` and `nixvim` as inputs and uses the
  `finalInputs: baseInputs` `mkFlake` signature.
- `hosts.nix` imports the two new modules alongside `development`.

### Terminal flake (`modules/terminal/`)

Inputs: `nixpkgs`, `home-manager`, `ghostty` (all followed from parent).

| File | Source | Exposes |
|---|---|---|
| `modules/zsh.nix` | moved from `development/zsh.nix` | zsh system + HM (aliases, prompt, plugins) |
| `modules/ghostty.nix` | ghostty + zellij from `development/editors.nix` | `nixpkgs.overlays`, `programs.ghostty`, `programs.zellij` |
| `modules/fonts.nix` | moved from `desktop/fonts.nix` | `fonts.packages = [iosevka]` |
| `modules/default.nix` | new | `flake.modules.nixos.terminal = { zsh, ghostty, fonts };` |

### Nixvim flake (`modules/nixvim/`)

Inputs: `nixpkgs`, `nixvim` (nixpkgs followed from parent).

| File | Source | Exposes |
|---|---|---|
| `modules/default.nix` | new | builds wrapper, sets `home-manager.users.${username}.programs.nvim` |
| `modules/_nixvim/` | moved from `development/_nixvim/` | nixvim config dir (unchanged) |

The wrapper:
```nix
nixvim' = inputs.nixvim.legacyPackages.${pkgs.system};
nvim = nixvim'.makeNixvimWithModule { inherit pkgs; module = ./_nixvim; };
flake.modules.nixos.nixvim = { home-manager.users.${username}.programs.nvim = nvim; };
```

The module takes `{pkgs, inputs, username, ...}` (matching `zsh.nix`'s arg pattern). The parent's
`_module.args` already provides `inputs/username/hostname/system/pkgs`; whether flake-parts
propagates those args to **sub-flake** modules must be verified (fallback: declare default args
in the nixvim flake).

## Steps

- [ ] Create `modules/terminal/flake.nix` (flake-parts module flake; inputs nixpkgs + home-manager + ghostty, all followed from parent; own flake.lock)
- [ ] Create `modules/terminal/modules/{zsh.nix,ghostty.nix,fonts.nix,default.nix}`
- [ ] Create `modules/nixvim/flake.nix` (inputs nixpkgs + nixvim; own flake.lock)
- [ ] Create `modules/nixvim/modules/{default.nix,_nixvim/}` (move the nixvim module dir)
- [ ] Move `zsh.nix`, `editors.nix`, `_nixvim/`, `desktop/fonts.nix` into the new flakes
- [ ] Update `desktop/default.nix` to drop the now-terminal-owned Iosevka font (avoid duplication)
- [ ] Update parent `flake.nix`: add `terminal` + `nixvim` inputs, switch to `finalInputs: baseInputs` mkFlake
- [ ] Update `modules/hosts.nix`: import `terminal` + `nixvim` modules on each host (earth/mars/jupiter) via `finalInputs`
- [ ] Verify `nix flake show` on the parent
- [ ] Verify evaluation + `nixos-system` still builds for earth/mars/jupiter
- [ ] Verify `alejandra` format on new/modified nix files
- [ ] Verify nixvim config is now applied (behavior change from the latent bug)

## Decisions (resolved — see "Resolved decisions" above)

All five original questions are resolved:
1. zellij → included in terminal flake.
2. nvim wrapper → nixvim flake owns it (applied via `programs.nvim`).
3. fonts → terminal flake owns Iosevka; desktop drops it.
4. layout → `modules/terminal` + `modules/nixvim`, ids `flake.modules.nixos.{terminal,nixvim}`.
5. wiring → flake-parts `finalInputs: baseInputs`.

## Open items for implementation (verify during build)

- **flake-parts arg propagation to sub-flakes:** confirm the parent's `_module.args` reaches the
  nixvim sub-flake's module. If not, declare default args in the nixvim flake.
- **nixvim module application context:** confirm the makeNixvimWithModule result applies cleanly
  as set on `home-manager.users.${username}.programs.nvim` (it was previously dead config in
  `home.packages`).
