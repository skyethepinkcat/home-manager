#!/usr/bin/env bash


DIR="${1:-.}"
OUT="${2:-combined.pdf}"

echo "$PATH"
mapfile -d '' pdfs < <(find "$DIR" -type f -iname '*.pdf' -print0 | grep -zZv 'US Bank' | grep -zZv 'peoplesoft'| sort -z)

if [ "${#pdfs[@]}" -eq 0 ]; then
  echo "No PDFs found in $DIR" >&2
  exit 1
fi

qpdf --empty --pages "${pdfs[@]}" -- "$OUT"
echo "Combined ${#pdfs[@]} PDFs into $OUT"
