#!/usr/bin/env bash

throw() { echo -e "$RED[-] failed: $1$RESET"; exit 1; }
clean-tmp() {
	rm -f tmp*.*;
	[[ -d "tmp-test-repo/.git" ]] && rm -rf tmp-test-repo;
}
setup-color() {
	if [[ -t 1 ]] && [[ "$(tput colors)" -ge 8 ]]; then
		BOLD="\x1b[1m"; RED="\x1b[31m"; GREEN="\x1b[32m"; RESET="\x1b[0m";
	fi
}
assert-expected-actual() {
	diff -u tmp-expected.log tmp-actual.log ||
		throw "actual log is not same as expected log!";
}
generate-wslgit() {
	local REPLACE_SIGN="need-to-be-replaced-in-unit-test";
	gawk -v replaceto="$1" '
		/^\s+#\s*region\s+'$REPLACE_SIGN'/ { print replaceto; ignore=1; next; }
		/^\s+#\s*endregion\s+'$REPLACE_SIGN'/ { ignore=0; next; }
		ignore { next; }
		{ print $0; }
	' ../wslgit.sh > tmp.sh || throw "generate tmp.sh for ci test failed!"
	chmod +x tmp.sh || throw;
}


_CWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)";
_PROJECT_DIR="$(dirname "$_CWD")";
setup-color;

# ==================_=======================
#   _ __ ___   __ _(_)_ __
#  | '_ ` _ \ / _` | | '_ \
#  | | | | | | (_| | | | | |
#  |_| |_| |_|\__,_|_|_| |_|
# ==========================================
pushd "$_CWD" || throw;
clean-tmp;

echo -e "$BOLD[.] generate tmp.sh (C: => ${_PROJECT_DIR})$RESET";
generate-wslgit "	echo 'C:\n$_PROJECT_DIR'";


echo -e "$BOLD[.] test 0x01: without argument $RESET";
git > tmp-expected.log
./tmp.sh > tmp-actual.log;
assert-expected-actual;

echo -e "$BOLD[.] test 0x01: git --version $RESET";
git --version > tmp-expected.log
./tmp.sh --version > tmp-actual.log;
assert-expected-actual;

echo -e "$BOLD[.] test 0x03: git rev-parse --show-toplevel $RESET";
echo "C:" > tmp-expected.log
./tmp.sh rev-parse --show-toplevel > tmp-actual.log;
assert-expected-actual;

echo -e "$BOLD[.] test 0x04: git init $RESET";
mkdir -p tmp-test-repo || throw;
pushd "tmp-test-repo" || throw;
../tmp.sh init || throw;

echo -e "$BOLD[.] test 0x05: git add file$RESET";
echo "# Just test" > 'this file.txt';
../tmp.sh add -v "C:\\test-ci\\tmp-test-repo\\this file.txt" || throw;

echo -e "$BOLD[.] test 0x06: git commit$RESET";
../tmp.sh commit -m "init commit" || throw;

echo -e "$BOLD[.] test 0x07: git git rev-parse --show-toplevel$RESET";
echo "C:\\test-ci\\tmp-test-repo" > tmp-expected.log
../tmp.sh rev-parse --show-toplevel > tmp-actual.log;
assert-expected-actual;

ARCHIVE_FILE='C:\\test-ci\\tmp-HEAD.zip';
echo -e "$BOLD[.] test 0x08: git archive -v --format=zip --output=$ARCHIVE_FILE HEAD$RESET";
../tmp.sh archive -v --format=zip --output="$ARCHIVE_FILE" HEAD || throw;
[[ -f ../tmp-HEAD.zip ]] || throw;

echo -e "$BOLD$GREEN[+] all tests success! $RESET";
popd; # exit directory tmp-test-repo

clean-tmp;
