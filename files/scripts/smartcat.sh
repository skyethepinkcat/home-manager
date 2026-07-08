if [ $# -eq 1 ] && [ -t 1 ] && [ -e "$1" ]; then

  if [ -d "$1" ]; then
    eza --icons auto "$@"
  elif [ ! -s "$1" ] || grep -qI '' "$1"; then
    cat "$@"
  else
    read -r -p "Not clear if $1 is a text file, are you sure you want to cat it? (y/N) " a && [[ $a =~ ^[Yy] ]] && cat "$@"
  fi

else

  # more than 1 argument implies we're actually concatonating files instead of reading them, so
  # fallback to normal behavior
  cat "$@"
fi
