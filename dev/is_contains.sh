#!/usr/bin/env bash

# usage: is_contains "$find" "$item1" "$item2" ...
function is_contains() {
	local it;
	for it in "${@:2}"; do
		if [[ "$it" == "$1" ]]; then
			return 0;
		fi
	done
	return 1;
}

if   is_contains "hello" "Mike!" "hello" "nice"; 			then echo "#1 ok!"; fi
if   is_contains "he llo" "he llo"; 						then echo "#2 ok!"; fi
if ! is_contains "hello" "Mike!" "helloo" "nice"; 			then echo "#3 ok!"; fi
if ! is_contains "hello";					 				then echo "#4 ok!"; fi
if ! is_contains "hello" "hello world"; 					then echo "#5 ok!"; fi
if ! is_contains "he llo" "hello" "he" "llo"; 				then echo "#6 ok!"; fi
