#!/bin/bash

TMPFILE=$(mktemp)

# Put stdin in the tmpfile
cat <&0 > "$TMPFILE"
puppet-lint --fix "$TMPFILE" &> /dev/null
cat "$TMPFILE"
