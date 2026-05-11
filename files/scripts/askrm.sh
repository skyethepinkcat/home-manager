#!/usr/bin/env bash

if type trash ; then
# shellcheck disable=SC2068 # Since $@ is being treated as command argument, we want to keep it.
  read -r -p "Are you sure you didn't mean trash? (y/N) " a && [[ "$a" =~ ^[Yy]$ ]] && rm $@
else
  rm $@
fi
