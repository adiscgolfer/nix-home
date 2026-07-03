# Daily workflow — which command do I run?

Three things get confused because they *sound* related but do different jobs.
Only one of them actually changes your system.

---

## What each does

### `direnv allow`
Loads the repo's **devshell** into your current shell — this is how you get `nh`
and the other helper tools on your PATH when you `cd` into the repo. It does
**not** touch your real config; it only affects the current shell.

Run it when:
- First time in the repo, or
- direnv nags `direnv: error .envrc is blocked` — this happens after you edit
  `.envrc`, `flake.nix`, or `flake.lock`.

Once allowed, just `cd`-ing into the repo re-loads the devshell automatically.

### `nh home switch .`
**Applies** your home-manager config. It builds the config, installs/removes
packages, and writes your dotfiles (zsh, starship, aliases). This is the **only**
step that actually mutates your system.

Run it when:
- You edited any `.nix` file under `home-configuration/` and want it live.

(For system-level macOS settings, the equivalent is `nh darwin switch .`.)

### Open a new terminal
Reloads zsh so **already-applied** changes take effect — new PATH entries, new
aliases, a changed `.zshrc`. It changes nothing itself; it just re-reads what
`switch` already wrote.

Run it when:
- After a `switch`, a tool or alias "isn't there yet" in your current shell.
- Shortcut: `exec zsh` reloads in place without opening a new window.

---

## Decision flow

| Situation | Do this |
|---|---|
| Edited a `.nix` file | `nh home switch .` → new terminal |
| Edited `.envrc` / `flake.nix` / `flake.lock` | `direnv allow` (if nagged) → `nh home switch .` |
| Tool / alias missing after a switch | new terminal (or `exec zsh`) |
| Just want `nh` + dev tools in this shell | `direnv allow` (auto-triggers on `cd`) |

---

## The one thing to remember

**Only `nh ... switch` mutates anything.**

- `direnv allow` = get the helper tools into *this* shell.
- New terminal / `exec zsh` = pick up what a switch already wrote.

Typical loop: **edit → `nh home switch .` → `exec zsh`**.
