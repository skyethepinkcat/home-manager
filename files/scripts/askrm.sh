#!/usr/bin/env bash

read -r -p "Are you sure you didn't mean trash? (y/N) " a && [[ "$a" =~ ^[Yy] ]] && rm "$@"
