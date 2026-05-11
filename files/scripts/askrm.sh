#!/usr/bin/env bash

if hash trash 2>/dev/null && [ -t 1 ]; then
# shellcheck disable=SC2068 # Since $@ is being treated as command argument, we want to keep it.
  read -r -p "Are you sure you didn't mean trash? (y/N) " a && [[ "$a" =~ ^[Yy] ]] && rm $@
else
# shellcheck disable=SC2068 # Since $@ is being treated as command argument, we want to keep it.
  rm $@
fi
