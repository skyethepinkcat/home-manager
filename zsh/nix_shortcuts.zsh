function ns() {
    if [[ $# -eq 0 ]]; then
        return 0
    fi

    declare -a arr=()
    for pkg in "$@"; do
        arr+=("nixpkgs#$pkg")
    done

    nix shell --impure "${arr[@]}"
}
