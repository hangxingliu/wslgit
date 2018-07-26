#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
pushd "$DIR";

AWK_FILE="../dev/to_unix_path.awk";

function main() {
	local result;  result=0;
	awk_test '#1' 'd:\test\file.txt' '/mnt/d/test/file.txt' || result=1;
	awk_test '#2' 'C:\Users\test\a space.txt' '/mnt/c/Users/test/a space.txt' || result=1;

	if [[ "$result" == "1" ]]; then
		echo "exit with code 1";
		exit 1;
	fi
}

function awk_test() {
	echo "$2" | awk -f "$AWK_FILE" |
		gawk -v expected="$3" -v name="$1" '
			{ actual = $0; }
			END {
				if(actual != expected) {
					print name " test failed:";
					print "  actual:   " actual;
					print "  expected: " expected;
					print "";
					exit 1;
				} else {
					print name " test passed!";
					exit 0;
				}
			}';
}
main;
