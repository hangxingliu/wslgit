#!/usr/bin/env bash

# The content of following base64 string is:
#   C: on /c type drvfs (rw,noatime,uid=1000,gid=1000,metadata,case=off)
# Related issue:
#   https://github.com/hangxingliu/wslgit/issues/8
function mock_mount_drvfs() {
	printf "%s%s" \
		Qzogb24gL2MgdHlwZSBkcnZmcyAocncsbm9hdGltZSx1aWQ9MTAwMCxnaWQ9MTAwMCxtZXRhZGF0 \
		YSxjYXNlPW9mZikK \
		| base64 --decode -;
}

function get_mounted_drvfs() {
	mock_mount_drvfs | mawk '
	function trim(s) { gsub(/^[ \t]+/, "", s); gsub(/[ \t]+$/, "", s); return s; }
	{
		if(split($0, lr, "type drvfs") < 2) next;
		if(split(lr[1], part, "on") < 2) next;

		drive = trim(part[1]); mount_to = trim(part[2]);
		print toupper(drive) "\n" mount_to;
	}';
}

function expected_result() { printf "%s\n%s\n" "C:" "/c"; }

expected="$(expected_result)"
actual="$(get_mounted_drvfs)";

echo "mock mount result: \"$(mock_mount_drvfs)\"";
[[ "$expected" == "$actual" ]] && exit 0;

echo "fatal: result of get_mounted_drvfs(mawk) is bad";
echo ">>>>>>>>>>>>>";
echo "expected:";
expected_result;
echo "=============";
echo "actual:";
get_mounted_drvfs;
echo "<<<<<<<<<<<<<";
