#!/bin/sh
### gitlint commit-msg hook start ###

# Determine whether we have a tty available by trying to access it.
# This allows us to deal with UI based gitclient's like Atlassian SourceTree.
# NOTE: "exec < /dev/tty" sets stdin to the keyboard
if [ -f .gitlint ]; then
  GITLINT_CONFIG=.gitlint
else
  GITLINT_CONFIG=~/.gitlint
fi

# If gitlint config is empty, ignore everything
if [ -s $GITLINT_CONFIG ]; then

  gitlint -C $GITLINT_CONFIG --staged --msg-filename "$1" run-hook
  exit_code=$?

  # If we fail to find the gitlint binary (command not found), let's retry by executing as a python module.
  # This is the case for Atlassian SourceTree, where $PATH deviates from the user's shell $PATH.
  if [ $exit_code -eq 127 ]; then
    echo "Fallback to python module execution"
    python -m gitlint.cli --staged --msg-filename "$1" run-hook
    exit_code=$?
  fi

  exit $exit_code
fi

### gitlint commit-msg hook end ###
