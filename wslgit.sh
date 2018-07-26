#!/usr/bin/env bash

AWK="awk"
[[ -n `which gawk` ]] && AWK="gawk"

function to_unix_path() {
	$AWK '{
		is_win_path = index($0, ":\\");
		if(is_win_path != 2) {
			print $0;
			exit;
		}

		part1 = "/mnt/" tolower(substr($0, 1, 1));
		part2 = substr($0, 3);

		gsub(/\\/, "/", part2);
		gsub("//", "/", part2);

		print part1 part2;
		exit;
	}';
}

function to_win_path() {
	$AWK '{
		print gensub(/\/mnt\/([A-Za-z])(\/\S*)/, "\\1:\\2", "g");
	}';
}

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

# log for debug
# __dirname="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# __now="$(date "+%y-%m-%d %H:%M:%S")"
# echo "${__now} $@" >> "$__dirname/wslgit.log";

git_stdin="/dev/stdin";
if is_contains "--version" "$@"; then
	git_stdin="/dev/zero";
fi

convert_output=false;
if is_contains "rev-parse" "$@" || is_contains "remote" "$@"; then
	convert_output=true;
fi

#git_arguments;
argument_count=0;
for argument in "$@"; do
	git_arguments[$argument_count]="$(echo "$argument" | to_unix_path)";
	argument_count=$(($argument_count+1));
done

# echo "${git_arguments[@]}";

if [[ "$convert_output" == "true" ]]; then
	git "${git_arguments[@]}" <&0 | to_win_path;
else
	git "${git_arguments[@]}" <&0;
fi

exit $?;
