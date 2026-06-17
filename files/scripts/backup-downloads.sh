TAR_FILE="$HOME/Documents/Download Archive/$(date +"%d-%m-%Y").tar"
tar -cf "$TAR_FILE" -T /dev/null
fd . "$HOME/Downloads" --changed-before=1month --exec-batch tar --append -f "$TAR_FILE"
pushd "$(dirname "$TAR_FILE")"
gzip "$(basename "$TAR_FILE")"
popd
fd . "$HOME/Downloads" --changed-before=1month --exec-batch trash
