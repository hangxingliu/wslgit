#!/usr/bin/env bash

#  Update: 2018-07-28
#  Author: Liu Yue (hangxingliu@gmail.com)
#
#  Description:
#    convert parameters from Windows path to Linux path by `wslpath` or `awk` if the parameter is a path
#    and launch git by given parameters and convert Linux path in git output to Windows path
#

# set default awk ve

# detect is `wslpath` in your WSL
test -n `which wslpath`;
HAS_WSLPATH=$?;

# if `wslpath` is not installed then use `awk` or `gawk`
AWK="awk";
if [[ $HAS_WSLPATH != 0 ]]; then
	[[ -n `which gawk` ]] && AWK="gawk";
fi

function to_unix_path_by_wslpath() {
	local unix_path;
	unix_path="$(wslpath "$1" 2>/dev/null)";
	# empty output means it is not a Linux path
	if [[ -z "$unix_path" ]]; then
		printf "%s" "$1";
	else
		printf "%s" "$unix_path";
	fi
}

function to_unix_path_by_awk() {
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

function to_win_path_by_wslpath() {
	local win_path;
	win_path="$(wslpath -w "$1" 2>/dev/null)";
	# empty output means it is not a Linux path
	if [[ -n "$win_path" ]]; then
		printf "%s" "$win_path";
	fi
}

function to_win_path_by_awk() {
	printf "%s" "$1" | $AWK -v mount_list="$(mount -t drvfs)" '
		BEGIN {
			split(mount_list, mount_array, "\n");
			replace_index = 1;
			for(key in mount_array) {
				split(mount_array[key], parts, "type drvfs");
				if(parts[1]) {
					part1 = parts[1];
					border = index(part1, "on");
					if(border > 1) {
						drive = substr(part1, 1, border - 1);
						mount_to = substr(part1, border + 3); # +3 => +2+1(1 more space character)

						gsub(/^\s/, "", drive);    gsub(/\s$/, "", drive);
						gsub(/^\s/, "", mount_to); gsub(/\s$/, "", mount_to);

						replace_from[replace_index] = mount_to;
						replace_to[replace_index++] = drive;
					}
				}
			}
		}
		{
			for(i = 1; i < replace_index ; i ++ )
				gsub(replace_from[i], replace_to[i]);
			print $0;
		}';
}

# function to_win_path_by_awk_old() {
#   $AWK '{
#     print gensub(/\/mnt\/([A-Za-z])(\/\S*)/, "\\1:\\2", "g");
#   }';
# }

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
# ======================
# __dirname="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# __now="$(date "+%y-%m-%d %H:%M:%S")"
# __logfile="$__dirname/wslgit.log";
# echo "${__now} $@" >> "$__logfile";
# ======================


# snippets for resolved Windows 10 1709 git hanging bug.
#   reference from https://github.com/andy-5/wslgit/blob/master/src/main.rs
# ======================
# git_stdin="/dev/stdin";
# if is_contains "--version" "$@"; then
# 	git_stdin="/dev/zero";
# fi
# ======================

# only convert stdout when parameters included `rev-parse` or `remote`
convert_output=false;
if is_contains "rev-parse" "$@" || is_contains "remote" "$@"; then
	convert_output=true;
fi

# convert each parameters to new array `git_arguments`
argument_count=0;
for argument in "$@"; do
	if [[ $HAS_WSLPATH == 0 ]]; then
		# by wslpath
		git_arguments[$argument_count]="$(to_unix_path_by_wslpath "$argument")";
	else
		# by awk/gawk
		git_arguments[$argument_count]="$(printf "%s" "$argument" | to_unix_path)";
	fi
	argument_count=$(($argument_count+1));
done

# log for debug
# ======================
# echo "${__now} ${git_arguments[@]}" >> "$__logfile";
# echo "${__now} argument count: $argument_count" >> "$__logfile";
# echo "=============" >> "$__logfile";
# ======================

# execute git
function execut_git() { git "${git_arguments[@]}" <&0; return $?; }

if [[ "$convert_output" == "true" ]]; then
	# save stdout of git to bash variable
	git_stdout="$(execut_git)";

	if [[ $HAS_WSLPATH == 0 ]]; then
		# test is the output of git only a Linux path
		fixed_stdout="$(to_win_path_by_wslpath "$git_stdout")";
	fi

	if [[ -n "$fixed_stdout" ]]; then
		# if the stdout of git only contains a linux path then just convert is by wslpath
		printf "%s" "$fixed_stdout";
	else
		# else convert linux path by awk following mount list `mount -t drvfs`
		printf "%s" "$(to_win_path_by_awk "$git_stdout")";
	fi
else
	execut_git;
fi

# set exit code same with git exited code
exit $?;
