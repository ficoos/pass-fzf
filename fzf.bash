#!/bin/bash

function path2entry() {
	local v=$1
	v=${v#$PREFIX/}
	v=${v%.gpg}
	echo -n "$v"
}

function entry2path() {
	echo -n $PREFIX/$1.gpg
}

function is_tty() {
	if tty | fgrep pts ; then
		return 0
	fi

	return 1
}

function candidate_selector_zenity() {
	candidates=$1
	echo -n "$candidates" | xargs -d '\n' zenity --list "--text=Password Store" --column=entries --mid-search --hide-header
}

function candidate_selector_fzf() {
	candidates=$1
	echo "$candidates" | fzf
}

path=$1
candidates=$(find "$PREFIX" -name '*.gpg' | while read -r c; do echo $(path2entry "$c"); done | grep -i "$1")
candidates_num=$(echo "$candidates" | wc -l)
passfile=
gui=is_tty
if [ -z "$candidates" -o $candidates_num == 0 ]; then
	die "Error: Could not find $path in password store."
elif [ $candidates_num == 1 ]; then
	echo $candidates
	passfile=$(entry2path $candidates)
else
	candidate_selector=candidate_selector_fzf
	if [ $gui == 0 ]; then
		candidate_selector=candidate_selector_zenity
	fi

	res=$($candidate_selector "$candidates")
	if [ -n "$res" ]; then
		passfile=$PREFIX/$res.gpg
	fi
fi

if [ -n "$passfile" ]; then
	$GPG -d "${GPG_OPTS[@]}" "$passfile" | tail -n +2 || exit $?
	pass_id=${passfile#$PREFIX/}
	pass_id=${pass_id%.gpg}
	pass show -c "$pass_id"
fi

