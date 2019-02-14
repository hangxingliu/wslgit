#!/usr/bin/env bash

# =========================================
#  Name:    wslgit.sh
#  Update:  2019-02-08
#  License: GPL-3.0
#  Author:  Liu Yue (hangxingliu@gmail.com)
#
#  Description:
#    Convert the Windows path contained in the arguments to Linux(WSL) path,
#       and convert the Linux(WSL) path in output of git to Windows path.
#    This script use `mount` command, awk scripts to implement above features.
#       I retained the implementation via `wslpath` codes in this script for
#       reference purposes only. (because wslpath has some shortcomings to
#       implement it)
# ==========================================

# Switch to enable/disable generate log file for debugging
WSLGIT_SH_LOG=${WSLGIT_SH_LOG:-false};
# WSLGIT_SH_LOG=${WSLGIT_SH_LOG:-true};

# Check is `wslpath` existed in the system
# https://blogs.msdn.microsoft.com/commandline/2018/03/07/windows10v1803/
# [[ -n `which wslpath` ]] && HAS_WSLPATH=true;

# Use gawk by default
AWK="$(which gawk)";
[[ -z "$AWK" ]] && AWK="$(which awk)";
[[ -z "$AWK" ]] && echo "fatal: \"awk\" is not installed in WSL!" >&2 && exit 1;

# ==========================================
# Iterate mounted drvfs (Windows drives) and save as multiline string
# Example output of `mount -d drvfs`:
#   D: on /tmp/wslgit-test-mount type drvfs (rw,relatime,umask=22,fmask=11)
# Example result of this function
#   C:
#   /mnt/c
#   D:
#   /tmp/wslgit-test-mount
function get_mounted_drvfs() {
	# region need-to-be-replaced-in-unit-test
	#     The previous line is used for mark the following statments
	#     need to be replaced to other implementation for unit test (travis-CI)
	mount -t drvfs | awk '{
		if(split($0, lr, "type drvfs") < 2) next;
		if(split(lr[1], part, "on") < 2) next;

		drive = part[1];     gsub(/^\s/, "", drive);    gsub(/\s$/, "", drive);
		mount_to = part[2];  gsub(/^\s/, "", mount_to); gsub(/\s$/, "", mount_to);
		print toupper(drive) "\n" mount_to;
	}';
	# endregion need-to-be-replaced-in-unit-test
}
MOUNTED_DRVFS="$(get_mounted_drvfs)";
# echo -e "$MOUNTED_DRVFS";

# ==========================================
# An implementation of path convertor via wslpath
# Why not use this implementation:
#   It can not convert the path which be mounted manually correctly
#   Get details info in the test "shortcomings of wslpath" in the file ./test-win/main.js
function to_unix_path_by_wslpath() {
	local unix_path;
	unix_path="$(wslpath "$1" 2>/dev/null)"; # empty output means it is not a Linux path
	[[ -n "$unix_path" ]] && printf "%s" "$unix_path" || printf "%s" "$1";
}
function to_win_path_by_wslpath() {
	local win_path;
	win_path="$(wslpath -w "$1" 2>/dev/null)"; # empty output means it is not a Linux path
	[[ -n "$win_path" ]] && printf "%s" "$win_path";
}


# ==========================================
# An implementation of path convertor via awk scripts and `mount` command
#
# Usage: to_unix_path_by_awk "$path"
function to_unix_path_by_awk() {
	# Awk script description:
	# If a line is starts like "C:\\", "D:\\", ...
	#   then find the correct path mapping from system mount info
	#   and replace the slash('\\') in path to back slash('/').
	# Else print line as normal
	# The result of `toupper(substr($0, 1, 2));` looks like: "C:", "D:", ...
	printf "%s" "$1"  |
		"$AWK" -v _mount="$MOUNTED_DRVFS" 'BEGIN { mount_len = split(_mount, mount_list, "\n"); }
		{
			if(index($0, ":\\") == 2) {
				driver = toupper(substr($0, 1, 2));
				for(i = 1; i <= mount_len ; i += 2 ) {
					if(driver != mount_list[i]) continue;
					suffix = substr($0, 3); gsub(/\\/, "/", suffix); gsub("//", "/", suffix);
					print mount_list[i+1] suffix;
					exit;
				}
			}
			print $0;
			exit;
		}';
}
# Usage: echo "$content_included_unix_path" | to_win_path_by_awk
function to_win_path_by_awk() {
	"$AWK" -v _mount="$MOUNTED_DRVFS" 'BEGIN { mount_len = split(_mount, mount_list, "\n"); }
		{
			for(i = 1; i <= mount_len ; i += 2 ) {
				if(gsub(mount_list[i+1], mount_list[i]) > 0) {
					gsub("/", "\\");
					break;
				}
			}
			print $0;
		}';
}

# ==================_=======================
#   _ __ ___   __ _(_)_ __
#  | '_ ` _ \ / _` | | '_ \
#  | | | | | | (_| | | | | |
#  |_| |_| |_|\__,_|_|_| |_|
# ==========================================

# Log for debugging
if [[ "$WSLGIT_SH_LOG" != false ]]; then
	log_file="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/wslgit.log";
	echo ">>> $(date "+%y-%m-%d %H:%M:%S")" >> "$log_file";
	echo "WSLGIT_SH_CWD: ${WSLGIT_SH_CWD}" >> "$log_file";
	echo "Arguments:" >> "$log_file"
	for arg in "$@"; do echo "  $arg" >> "$log_file"; done
fi

# Fix cwd(currency working directory) by environmnt variable WSLGIT_SH_CWD
# Sample case:
#   You mount drive D: manually on /mnt/d. Then you use `git.bat` on drive D:
#   The cwd of wsl will be user home directory because wsl can not handler cwd correctly
if [[ -n "$WSLGIT_SH_CWD" ]]; then
	correct_cwd="$(to_unix_path_by_awk "$WSLGIT_SH_CWD")";
	cd "$correct_cwd";
	[[ "$?" != 0 ]] && echo "fatal: can not cd to ${WSLGIT_SH_CWD} ($correct_cwd)" >&2 && exit 1;
fi

# Snippets for resolved Windows 10 1709 git hanging bug.
#   reference from https://github.com/andy-5/wslgit/blob/master/src/main.rs
# >>>
# git_stdin="/dev/stdin";
# for arg in "${@}"; do [[ "$arg" == "--version" ]] && git_stdin="/dev/zero"; done
# <<<


# Convert each arguments to new array `git_args`
# And used to check should output of git need convert
argv=0;
convert_output=false;
after_double_dash=false;
for arg in "$@"; do
	if [[ "$after_double_dash" != true ]]; then
		if [[ "$arg" == "rev-parse" ]] || [[ "$arg" == "remote" ]]; then
			convert_output=true;
		fi
		# convert long form argument
		if [[ "$arg" == --*=* ]]; then
			prefix="${arg%%=*}";
			file_path="${arg#*=}";
			git_args[$argv]="${prefix}=$(to_unix_path_by_awk "$file_path")";
			argv=$(($argv+1));
			continue;
		fi
	fi
	[[ "$arg" == "--" ]] && after_double_dash=true;

	git_args[$argv]="$(to_unix_path_by_awk "$arg")";
	argv=$(($argv+1));
done

# Log for debugging
if [[ "$WSLGIT_SH_LOG" != false ]]; then
	echo "cwd: $(pwd)" >> "$log_file";
	echo "Converted arguments:" >> "$log_file";
	for arg in "${git_args[@]}"; do echo "  $arg" >> "$log_file"; done
	echo "<<<" >> "$log_file";
fi

# Execute git with git_args
function execut_git() { git "${git_args[@]}" <&0; return $?; }
if [[ "$convert_output" == true ]]; then
	execut_git | to_win_path_by_awk;
else
	execut_git;
fi

# set exit code same with git exited code
exit $?;
