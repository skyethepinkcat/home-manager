if [[ $# -eq 0 ]]; then
    exit 0
fi

nix run "nixpkgs#$1"
