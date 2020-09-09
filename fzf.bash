#!/bin/bash

function candidates() {
    find "$PREFIX" -name '*.gpg' -printf '%P\n' | sed -e 's:.gpg$::gi'
}

function candidate_selector_fzf() {
	query=$1
	candidates | fzf -q "$query" --select-1
}

query="$@"

res=$(candidate_selector_fzf "$query")
if [ -n "$res" ]; then
	pass show "$res" | tail -n +2 || exit $?
	pass show -c "$res"
else
	exit 1
fi

