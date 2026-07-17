# nix-home

## Session-start check: watchexec pin

`flake.nix` carries a temporary `nixpkgs-watchexec` input (pinned to nixpkgs
`e8273b2`) plus an overlay in `homeConfigurations`, because watchexec on
current unstable has no cache.nixos.org binary and fails to link locally
(cctools ld crash on macOS 26).

At the start of each session in this repo, run:

```bash
nix path-info --store https://cache.nixos.org $(nix eval --raw nixpkgs#watchexec.outPath)
```

- **Succeeds (exit 0)**: the cache has watchexec again. Tell the user, then
  remove the `nixpkgs-watchexec` input and the overlay from `flake.nix`, run
  `nix flake update`, and delete this section.
- **Fails**: pin still needed; mention it briefly and move on.

If this section is gone, the pin was already cleaned up — no action needed.
