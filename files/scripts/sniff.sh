#!/bin/bash
if [[ $# -eq 1 ]]; then
INTERFACE="eno1"
else
INTERFACE="$2"
fi

PIPE_FILE="/tmp/remote.$1"
if [ ! -e "$PIPE_FILE" ]; then
mkfifo "$PIPE_FILE"
fi
# shellcheck disable=SC2029 # $INTERFACE is a part of the script, so it should be expanded on the client
ssh "root@$1" "tcpdump -s 0 -U -n -w - -i $INTERFACE not port 22" > "$PIPE_FILE" &
sleep 5
wireshark -k -i "$PIPE_FILE" &
