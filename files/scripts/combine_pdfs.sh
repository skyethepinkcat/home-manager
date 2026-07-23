#!/usr/bin/env bash


DIR="${1:-.}"
OUT="${2:-combined.pdf}"

mapfile -d '' pdfs < <(find "$DIR" -type f -iname '*.pdf' -print0 | sort -z | grep -v 'US Bank' | grep -v 'peoplesoft')

if [ "${#pdfs[@]}" -eq 0 ]; then
  echo "No PDFs found in $DIR" >&2
  exit 1
fi

qpdf --empty --pages "${pdfs[@]}" -- "$OUT"
echo "Combined ${#pdfs[@]} PDFs into $OUT"
