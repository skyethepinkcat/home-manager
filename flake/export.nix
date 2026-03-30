# flake/export.nix
#
# Adds packages.<system>.dotfiles{,-ii69854,-skye} outputs that export
# the home-manager-managed config files in a portable form suitable for
# non-Nix machines.
#
# What it does:
#   • Reads every file in config.home.file (includes all program-generated
#     configs: starship.toml, git config, kitty.conf, lazygit, eza, zshrc, …)
#   • Drops entries marked executable (nix-wrapped binaries)
#   • Normalises absolute paths by stripping the homeDirectory prefix so the
#     output tree is always rooted at "." (i.e. suitable for rsync to $HOME)
#   • Skips paths outside $HOME (e.g. /Library/Fonts) and nix-specific dirs
#   • Replaces the nix-generated .config/nvim with nixvim-config's own
#     nvim-config-export package, which is pre-stripped for non-nix use
#   • Rewrites three classes of /nix/store references:
#       - Shebangs      #!/nix/store/…/bin/bash  →  #!/usr/bin/env bash
#       - source lines  source /nix/store/…      →  # [nix-export: removed]
#       - Bare prefixes /nix/store/hash-name/     →  (stripped)
#   • Copies raw .sh sources from files/scripts/ into .local/bin/
#   • Emits an install.sh that copies the tree into $HOME
#
# Usage (after `nix build .#dotfiles`):
#   ls result/
#   ./result/install.sh          # install to $HOME
#   tar czf dots.tar.gz -C result .   # ship somewhere else

{ inputs, lib, ... }:
{
  perSystem =
    {
      pkgs,
      system,
      ...
    }:
    let
      # Re-declare mkHomeConfig here so this module is self-contained.
      mkHomeConfig =
        username:
        inputs.home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ../home.nix ];
          extraSpecialArgs = {
            inherit system username inputs;
          };
        };

      mkDotfilesExport =
        username:
        let
          hmConfig = mkHomeConfig username;
          homeDir = hmConfig.config.home.homeDirectory; # e.g. /Users/ii69854
          hmFiles = hmConfig.config.home.file;

          # home.file keys can be either relative ("config/foo") or absolute
          # ("/Users/ii69854/.config/foo").  Normalise to a relative path, or
          # return null for paths that live outside $HOME entirely.
          normalizePath =
            k:
            let
              stripped = lib.removePrefix homeDir k;
            in
            if stripped != k then
              # Was an absolute path inside HOME — strip the leading "/"
              lib.removePrefix "/" stripped
            else if lib.hasPrefix "/" k then
              # Absolute path NOT under HOME (e.g. /Library/Fonts) — skip
              null
            else
              # Already a relative path
              k;

          # Relative path prefixes that are nix-specific or non-portable.
          # These are excluded from the export even if they pass other filters.
          # Note: .config/nvim is handled separately via nixvim-config's own export package.
          excludePrefixes = [
            ".config/nvim" # replaced below with nixvim-config's nvim-config-export output
            ".local/state" # empty placeholder .keep files
            ".cache" # empty placeholder .keep files
            "Library/" # macOS system directories (fonts, etc.) — not $HOME dotfiles
          ];

          isExcluded = rel: builtins.any (p: lib.hasPrefix p rel) excludePrefixes;

          # Build the final set of files to export:
          #   key   = normalised relative path  (used as destination under $out)
          #   value = home.file entry           (.source, .recursive, …)
          exportFiles = lib.listToAttrs (
            lib.concatMap (
              k:
              let
                v = hmFiles.${k};
                norm = normalizePath k;
              in
              if v.executable || norm == null || isExcluded norm then
                [ ] # drop
              else
                [
                  {
                    name = norm;
                    value = v;
                  }
                ]
            ) (lib.attrNames hmFiles)
          );
        in
        pkgs.runCommand "dotfiles-${username}"
          {
            nativeBuildInputs = with pkgs; [
              gnused
              findutils
              coreutils
            ];
          }
          ''
            set -euo pipefail

            # Rewrite three categories of nix store references:
            #   1. Shebangs pointing into the store  →  #!/usr/bin/env PROG
            #   2. `source /nix/store/…` lines       →  commented-out note
            #   3. Bare store-path prefixes           →  stripped
            sanitize() {
              sed \
                -e 's|#!/nix/store/[^/]*/bin/\([^ ]*\)|#!/usr/bin/env \1|g' \
                -e 's|source /nix/store/[^ ]*|# [nix-export: removed nix-store source — install plugin manually]|g' \
                -e 's|/nix/store/[^/]*/||g' \
                "$1"
            }

            mkdir -p $out

            # ── managed config files ───────────────────────────────────────
            ${lib.concatStringsSep "\n" (
              lib.mapAttrsToList (rel: cfg: ''
                src="${cfg.source}"
                dest="$out/${rel}"
                mkdir -p "$(dirname "$dest")"
                if [ -f "$src" ]; then
                  sanitize "$src" > "$dest"
                elif [ -d "$src" ]; then
                  cp -rT "$src" "$dest"
                  chmod -R u+w "$dest"
                  find "$dest" -type f | while IFS= read -r f; do
                    tmp=$(mktemp)
                    sanitize "$f" > "$tmp"
                    mv "$tmp" "$f"
                  done
                fi
              '') exportFiles
            )}

            # ── neovim config (pre-stripped by nixvim-config's own export) ───
            # nixvim-config exposes packages.<system>.nvim-config-export, which
            # is already sanitised for non-nix use (no tree-sitter store paths).
            # We still run sanitize() over it to catch any stray shebangs left
            # in plugin script files (test/docs helpers etc.).
            cp -rT "${inputs.nixvim-config.packages.${system}.nvim-config-export}" \
              "$out/.config/nvim"
            chmod -R u+w "$out/.config/nvim"
            # Remove nix-support/ dirs — nix package metadata, useless outside nix
            find "$out/.config/nvim" -type d -name 'nix-support' \
              | xargs -r rm -rf
            # Sanitize any remaining shebangs / store-path refs in text files
            find "$out/.config/nvim" -type f | while IFS= read -r f; do
              tmp=$(mktemp)
              sanitize "$f" > "$tmp"
              mv "$tmp" "$f"
            done

            # ── raw shell scripts (unwrapped, portable) ────────────────────
            mkdir -p $out/.local/bin
            for f in ${../files/scripts}/*.sh; do
              name="$(basename "$f" .sh)"
              sanitize "$f" > "$out/.local/bin/$name"
              chmod +x "$out/.local/bin/$name"
            done

            # ── install helper ─────────────────────────────────────────────
            cat > $out/install.sh << 'INSTALLEOF'
            #!/usr/bin/env bash
            # install.sh — copy exported dotfiles into $HOME
            #
            # Usage:
            #   ./install.sh           dry-run: shows what would be installed/overwritten
            #   ./install.sh --apply   actually install (prompts before clobbering)
            #
            # Any file that already exists at the target path is flagged before
            # being overwritten.  You will be asked once whether to proceed.
            set -euo pipefail

            DOTFILES_DIR="$(cd "$(dirname "''${BASH_SOURCE[0]}")" && pwd)"
            APPLY=false
            [[ "''${1:-}" == "--apply" ]] && APPLY=true

            # ── collect all files to install (excluding this script itself) ──
            files=()
            while IFS= read -r -d $'\0' f; do
              rel="''${f#"$DOTFILES_DIR"/}"
              [[ "$rel" == "install.sh" ]] && continue
              files+=("$rel")
            done < <(find "$DOTFILES_DIR" -type f -print0)

            # ── check for files that would be overwritten ──────────────────
            conflicts=()
            for rel in "''${files[@]}"; do
              target="$HOME/$rel"
              [[ -e "$target" ]] && conflicts+=("$target")
            done

            if [[ ''${#conflicts[@]} -gt 0 ]]; then
              echo "The following existing files would be overwritten:"
              for f in "''${conflicts[@]}"; do
                echo "  $f"
              done
              echo ""
              if ! $APPLY; then
                echo "Dry-run complete.  Re-run with --apply to install."
                exit 0
              fi
              read -r -p "Overwrite the above files? [y/N] " reply
              [[ "''${reply}" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 1; }
            elif ! $APPLY; then
              echo "Dry-run: no conflicts found."
              echo "Files that would be installed:"
              for rel in "''${files[@]}"; do
                echo "  $HOME/$rel"
              done
              echo ""
              echo "Re-run with --apply to install."
              exit 0
            fi

            # ── install ────────────────────────────────────────────────────
            for rel in "''${files[@]}"; do
              target="$HOME/$rel"
              mkdir -p "$(dirname "$target")"
              cp -v "$DOTFILES_DIR/$rel" "$target"
            done

            echo ""
            echo "Done — dotfiles installed to $HOME"
            INSTALLEOF
            chmod +x $out/install.sh
          '';
    in
    {
      packages = {
        dotfiles = mkDotfilesExport "ii69854";
        dotfiles-ii69854 = mkDotfilesExport "ii69854";
        dotfiles-skye = mkDotfilesExport "skye";
      };
    };
}
