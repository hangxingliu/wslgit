#!/usr/bin/env bash

# usage: is_contains "$find" "$item1" "$item2" ...
function is-contains() {
	local it;
	for it in "${@:2}"; do
		if [[ "$it" == "$1" ]]; then
			return 0;
		fi
	done
	return 1;
}

if ! is-contains "hello" "Mike!" "hello" "nice"; 			then echo "fatal: 1 failed!"; exit 1; fi
if ! is-contains "he llo" "he llo"; 						then echo "fatal: 2 failed!"; exit 1; fi
if   is-contains "hello" "Mike!" "helloo" "nice"; 			then echo "fatal: 3 failed!"; exit 1; fi
if   is-contains "hello";					 				then echo "fatal: 4 failed!"; exit 1; fi
if   is-contains "hello" "hello world"; 					then echo "fatal: 5 failed!"; exit 1; fi
if   is-contains "he llo" "hello" "he" "llo"; 				then echo "fatal: 6 failed!"; exit 1; fi
echo "all done!";
