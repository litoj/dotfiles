#!/usr/bin/bash
[[ $TERM ]] && ranger "$@" 2> /dev/null || xterm ranger "$@"
