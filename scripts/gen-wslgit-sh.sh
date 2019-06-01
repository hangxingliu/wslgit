#!/usr/bin/env bash

# ===========================================
#  This script is used for generating
#    `wslgit.sh` from `wslgit.dev.sh`.
#  And this script will remove its comments,
#    log logic and debug logic.
# ===========================================

INPUT="wslgit.dev.sh";
OUTPUT="wslgit.sh";

throw() { echo -e "fatal: $1"; exit 1; }

cd "$( dirname "${BASH_SOURCE[0]}" )/.." || throw "goto project directory failed!";
[[ -n "$(which gawk)" ]] || throw "gawk is not installed!";
[[ -f "$INPUT" ]] || throw "${INPUT} is not a file!";

AWK_REMOVE_LOG='
	BEGIN { keep_line=1; }
	/#region[ \t]+log/ { keep_line=0; next; }
	/#endregion[ \t]+log/ { keep_line=1; next; }
	/WSLGIT_SH_LOG/ { next; }
	keep_line { print; }
';

AWK_REMOVE_COMMENTS='
	BEGIN { keep_line=0; }
	/^#!/ { print; next; } # keep shebang comment
	keep_line==1 { print; }
	/^[ \t]*#[ \t]+[=]+/ { if(!keep_line) print; keep_line++; next; }
	/^[ \t]*#/ { next; }
	{ print; }
'

AWK_REMOVE_MUTLIPLE_EMPTY_LINES='
	/^$/ { i++; if(i>=2) next; }
	!/^$/ { i=0; }
	{ print; }
';

AWK_ADD_WARNING='
	function warning(info) { print "# WARNING: " info; }
	NR == 3 {
		warning("DO NOT EDIT THIS FILE MANUALLY!");
		warning("Because This file is generated from '$INPUT' by ./script/gen-wslgit-sh.sh");
		print("");
	}
	{ print; }
'


cat "$INPUT" |
	gawk "$AWK_REMOVE_LOG" |
	gawk "$AWK_REMOVE_COMMENTS" |
	gawk "$AWK_REMOVE_MUTLIPLE_EMPTY_LINES" |
	gawk "$AWK_ADD_WARNING" \
	> "$OUTPUT" || throw "generate failed!";

echo "success: ${INPUT} -> ${OUTPUT}";