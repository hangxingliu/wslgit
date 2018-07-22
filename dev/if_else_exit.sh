#!/usr/bin/env bash

function ret() {
	if [[ "$1" == "1" ]]; then
		return 1;
	fi
	return 0;
}

predefine="0";
if [[ "$predefine" == "1" ]]; then
	ret 1;
else
	ret 0;
fi

echo "$?";
