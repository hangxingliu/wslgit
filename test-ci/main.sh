#!/usr/bin/env bash

#=============================
#region Utils function
throw() {
	echo -e "$RED[-] failed: $1$RESET";
	exit 1;
}
clean-tmp-files() {
	rm -f tmp*.*;
	[[ -d "tmp-test-repo/.git" ]] && rm -rf tmp-test-repo;
}
setup-color-variables() {
	if [[ -t 1 ]] && [[ "$(tput colors)" -ge 8 ]]; then
		BOLD="\x1b[1m"; RED="\x1b[31m"; GREEN="\x1b[32m"; RESET="\x1b[0m";
	fi
}
print-test-header() {
	[[ -z "$test_counter" ]] && test_counter=1;
	printf "$BOLD[.] test 0x%x: %s$RESET\n" "$test_counter" "$1";
	test_counter=$(($test_counter+1));
}
assert-expected-actual() {
	diff -u tmp-expected.log tmp-actual.log ||
		throw "actual log is not same as expected log!";
}
UNIT_TEST_SIGN="need-to-be-replaced-in-unit-test";
generate-wslgit-with-mock-mount-info() {
	gawk -v replaceto="$1" '
		/^\s+#\s*region\s+'$UNIT_TEST_SIGN'/ { print replaceto; ignore=1; next; }
		/^\s+#\s*endregion\s+'$UNIT_TEST_SIGN'/ { ignore=0; next; }
		ignore { next; }
		{ print $0; }
	' ../wslgit.sh > tmp.sh || throw "generate tmp.sh for ci test failed!"
	chmod +x tmp.sh || throw;
}

setup-color-variables;
#endregion
#=============================


_CWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)";
_PROJECT_DIR="$(dirname "$_CWD")";

# ==================_=======================
#   _ __ ___   __ _(_)_ __
#  | '_ ` _ \ / _` | | '_ \
#  | | | | | | (_| | | | | |
#  |_| |_| |_|\__,_|_|_| |_|
# ==========================================
main() {
	pushd "$_CWD" || throw;
	clean-tmp-files;

	echo -e "$BOLD[.] check dependencies $RESET";
	echo "    gawk: $(ls -al "$(which gawk)")";
	echo "    mawk: $(ls -al "$(which mawk)")";
	[[ -n "$(which gawk)" ]] || throw "gawk is not installed!";
	[[ -n "$(which mawk)" ]] || throw "mawk is not installed!";

	echo -e "$BOLD[.] test bash snippets $RESET";
	./bash-snippets/is-contains.sh || throw;
	./bash-snippets/drvfs-list-with-mawk.sh || throw;
	exit;

	echo -e "$BOLD[.] generate tmp.sh (gawk, C: => ${_PROJECT_DIR})$RESET";
	generate-wslgit-with-mock-mount-info  "	echo 'C:\n$_PROJECT_DIR'";
	start-test;

	echo -e "$BOLD[.] generate tmp.sh (mawk, C: => ${_PROJECT_DIR})$RESET";
	gawk '/gawk/ { gsub("gawk", "mawk"); } { print $0; }' ./tmp.sh > ./tmp2.sh || throw;
	mv ./tmp2.sh ./tmp.sh && chmod +x tmp.sh || throw;
	start-test;

	echo -e "$BOLD$GREEN[+] all tests success! $RESET";
	clean-tmp-files;
}

start-test() {
	print-test-header "without argument";
	git > tmp-expected.log
	./tmp.sh > tmp-actual.log;
	assert-expected-actual;

	print-test-header "git --version";
	git --version > tmp-expected.log
	./tmp.sh --version > tmp-actual.log;
	assert-expected-actual;

	print-test-header "git rev-parse --show-toplevel";
	echo "C:" > tmp-expected.log
	./tmp.sh rev-parse --show-toplevel > tmp-actual.log;
	assert-expected-actual;

	print-test-header "git init";
	if [[ -d tmp-test-repo ]]; then rm -r tmp-test-repo || throw; fi
	mkdir -p tmp-test-repo || throw;
	pushd "tmp-test-repo" || throw;
	../tmp.sh init || throw;

	print-test-header "git add file";
	echo "# Just test" > 'this file.txt';
	../tmp.sh add -v "C:\\test-ci\\tmp-test-repo\\this file.txt" || throw;

	print-test-header "git commit";
	../tmp.sh commit -m "init commit" || throw;

	print-test-header "git git rev-parse --show-toplevel";
	echo "C:\\test-ci\\tmp-test-repo" > tmp-expected.log
	../tmp.sh rev-parse --show-toplevel > tmp-actual.log;
	assert-expected-actual;

	ARCHIVE_FILE='C:\\test-ci\\tmp-HEAD.zip';
	print-test-header "git archive -v --format=zip --output=$ARCHIVE_FILE HEAD";
	../tmp.sh archive -v --format=zip --output="$ARCHIVE_FILE" HEAD || throw;
	[[ -f ../tmp-HEAD.zip ]] || throw;

	popd; # exit directory tmp-test-repo
}

# launch from main function
main
