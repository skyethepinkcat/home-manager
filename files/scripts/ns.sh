if [[ $# -eq 0 ]]; then
    exit 0
fi

declare -a arr=()
for pkg in "$@"; do
    arr+=("nixpkgs#$pkg")
done

echo "${arr[@]}" | xargs nix shell --impure
