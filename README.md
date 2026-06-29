# nix-home

Personal macOS configuration managed with [Lix](https://lix.systems) (a friendly Nix fork), [nix-darwin](https://github.com/LnL7/nix-darwin), and [home-manager](https://github.com/nix-community/home-manager).

Pull this repo on a new Mac, follow the steps below, and you'll have your full environment back in minutes.

---

## What this configures

- **Shell**: zsh + [Starship](https://starship.rs) prompt + [Atuin](https://atuin.sh) shell history
- **Terminal**: Alacritty with Dracula theme and MesloLGS Nerd Font
- **CLI tools**: modern replacements for `ls`, `cat`, `grep`, `find`, and more
- **Git**: delta for diffs, lazygit TUI, GitHub CLI
- **Docker**: Colima (no Docker Desktop needed), lazydocker TUI, dive
- **Go**: compiler, gopls language server, golangci-lint, delve debugger
- **Other**: fzf, jq, yq, httpie, direnv, claude-code, and more

---

## Prerequisites

- A Mac with **Apple Silicon** (M1/M2/M3/M4). The flake is pinned to `aarch64-darwin`. Intel Macs would need `x86_64-darwin` in `flake.nix`.
- **Xcode Command Line Tools** — install them first if you haven't:
  ```
  xcode-select --install
  ```

---

## Step 1 — Install Lix

[Lix](https://lix.systems) is a community fork of Nix with a better installer and friendlier errors. It is fully compatible with the standard Nix ecosystem, so everything in this repo works with it.

Run the installer:
```sh
curl -sSf -L https://install.lix.systems/lix | sh -s -- install
```

Follow the prompts. When it finishes, **open a new terminal** (or source your shell profile) so the `nix` command is on your PATH.

Verify it worked:
```sh
nix --version
```

> **Note:** If you prefer stock Nix instead of Lix, the [Determinate Systems installer](https://github.com/DeterminateSystems/nix-installer) is the recommended alternative. The rest of this guide works the same either way.

---

## Step 2 — Clone this repo

```sh
git clone https://github.com/adiscgolfer/nix-home.git ~/projects/utils/nix-home
cd ~/projects/utils/nix-home
```

---

## Step 3 — Update your username and hostname in flake.nix

Open `flake.nix` and find these two lines near the top of the `let` block:

```nix
username = "adiscgolfer";
hostname  = "mbp-adg";
```

- **`username`** must match your macOS login username. Find yours with:
  ```sh
  whoami
  ```
- **`hostname`** must match your Mac's local hostname. Find yours with:
  ```sh
  scutil --get LocalHostName
  ```

Update both values, save, and continue.

---

## Step 4 — Bootstrap nix-darwin

nix-darwin manages system-level macOS settings. You only need to bootstrap it once; after that, all rebuilds go through the devshell (see Step 7).

```sh
nix run nix-darwin -- switch --flake ".#$(scutil --get LocalHostName)"
```

This will take a few minutes the first time as it downloads everything. When it finishes, **open a new terminal** — your shell is now managed by nix-darwin.

---

## Step 5 — Apply your home-manager configuration

home-manager manages everything in your home directory: shell config, dotfiles, user packages.

```sh
nix run home-manager/master -- switch --flake ".#$(whoami)"
```

Again, open a new terminal when it's done. You should now have your full prompt, aliases, and tools available.

---

## Step 6 — Set up your secrets file

zsh is configured to automatically source `~/.secrets` if the file exists. This is where you keep things that should never live in git — API keys, tokens, work credentials, etc.

Create the file:
```sh
touch ~/.secrets
chmod 600 ~/.secrets
```

Then add exports to it as needed:
```sh
# Example contents of ~/.secrets
export GITHUB_TOKEN="ghp_..."
export SOME_API_KEY="..."
```

---

## Step 7 — Enter the devshell for day-to-day use

The repo includes a devshell with helper commands for managing your setup. From inside the repo directory, run:

```sh
nix develop
```

You'll see a menu of available commands. The most useful one:

| Command | What it does |
|---|---|
| `update-everything` | Updates `flake.lock`, rebuilds darwin + home configs, and runs garbage collection |
| `nh darwin switch .` | Apply only macOS/darwin changes |
| `nh home switch .` | Apply only home-manager changes |
| `nh clean all` | Garbage collect old generations |

---

## Making changes

1. Edit any `.nix` file in the repo.
2. Run `nix develop` to enter the devshell (if not already in it).
3. Run `nh home switch .` (for user/package changes) or `nh darwin switch .` (for system changes).

Changes are applied atomically — if a build fails, your previous config stays active.

---

## Troubleshooting

**`error: experimental Nix feature 'flakes' is disabled`**
Flakes should be enabled automatically by the installer. If not, add this to `/etc/nix/nix.conf`:
```
experimental-features = nix-command flakes
```

**Hostname not found in flake**
If `darwin-rebuild` or `home-manager` says it can't find your configuration, double-check that the `hostname` and `username` in `flake.nix` exactly match what `scutil --get LocalHostName` and `whoami` return.

**Alacritty opens but fonts look wrong**
The MesloLGS Nerd Font is installed by nix, but macOS may not see it until you run:
```sh
fc-cache -f -v
```
Or log out and back in.

**`darwin-rebuild` command not found after Step 4**
Open a new terminal window — nix-darwin adds itself to PATH via `/etc/zshrc`, which is only sourced in new shells.
