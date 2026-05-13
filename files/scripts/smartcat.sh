if [ $# -eq 1 ] && [ -d "$1" ]; then
  eza --icons auto "$@"
else
  cat "$@"
fi
