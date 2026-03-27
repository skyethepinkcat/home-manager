# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

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

This is a [Home Manager](https://github.com/nix-community/home-manager) configuration as a Nix flake targeting two users (`ii69854` and `skye`) across four systems (x86_64/aarch64 Linux/Darwin).

**Entry points:**
- `flake.nix` — defines inputs and exposes `legacyPackages.homeConfigurations.<username>` via `flake-parts`. The formatter is `nixfmt`.
- `home.nix` — root Home Manager module; imports all sub-modules and wires up `shell-script` helpers, session vars, aliases, and core program settings (git, ssh, lazygit, kitty, eza, direnv, yazi).
- `packages.nix` — standalone package list imported by `home.nix`.

**Sub-modules** (each is a directory with `default.nix`):
- `darwin/` — macOS-specific defaults gated behind `darwinConfig.enable` (auto-detected from `hostPlatform`).
- `neovim/` — custom `neovim-config` option set; supports switching between NvChad (`use-nvchad`) and Nixvim (`use-nixvim`). Currently uses Nixvim, sourced from the private `nixvim-config` flake input.
- `zsh/` — Zsh configuration with fast-syntax-highlighting, history substring search, and inline zsh snippets from `nix_shortcuts.zsh` / `win_title_functions.zsh`.
- `starship/` — Starship prompt config.
- `vim/` — Vim configuration.

**Shell scripts** live in `files/scripts/*.sh` and are wrapped via the `shell-script` helper in `home.nix` into proper Nix derivations using `pkgs.writeShellApplication`.

**Theme:** Catppuccin Mocha throughout (bat, eza, lazygit).

**Private flake inputs** (`nixvim-config`, `nvchad-config`) are fetched over SSH — ensure SSH keys and agent are configured before running `nix flake update` on those inputs.
