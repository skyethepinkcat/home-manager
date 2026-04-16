# CLAUDE.md

Guidance for Claude Code when working in this repo.

## Commands

```bash
# Apply configuration (default - also updates nixvim-config flake input first)
make
# or
make switch

# Build without activating
make build

# Format Nix files
nix fmt

# Enter dev shell (provides nil, nixfmt, shfmt)
nix develop

# Update all flake inputs
nix flake update

# Update a specific input
nix flake update <input-name>
```

## Architecture

[Home Manager](https://github.com/nix-community/home-manager) config as Nix flake. Two users (`ii69854`, `skye`), four systems (x86_64/aarch64 Linux/Darwin).

**Entry points:**
- `flake.nix` — defines inputs, exposes `legacyPackages.homeConfigurations.<username>` via `flake-parts`. Formatter: `nixfmt`.
- `home.nix` — root HM module; imports sub-modules, wires `shell-script` helpers, session vars, aliases, core programs (git, ssh, lazygit, kitty, eza, direnv, yazi).
- `packages.nix` — standalone package list imported by `home.nix`.

**Sub-modules** (each dir has `default.nix`):
- `darwin/` — macOS defaults gated behind `darwinConfig.enable` (auto-detected from `hostPlatform`).
- `neovim/` — custom `neovim-config` option; uses Nixvim from `nixvim-config` flake input.
- `zsh/` — Zsh config with fast-syntax-highlighting, history substring search, inline snippets from `nix_shortcuts.zsh` / `win_title_functions.zsh`.
- `starship/` — Starship prompt config.
- `vim/` — Vim config.

**Shell scripts** in `files/scripts/*.sh`, wrapped via `shell-script` helper in `home.nix` into Nix derivations using `pkgs.writeShellApplication`.

**Theme:** Catppuccin Mocha throughout (bat, eza, lazygit).

**Private flake inputs:** none — `nixvim-config` public repo, fetched over HTTPS.
