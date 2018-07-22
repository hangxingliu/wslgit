#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
pushd "$DIR";

if [[ -t 1 ]]; then # is terminal?
	COLOR_MODE=`tput colors`;
	if [[ -n "$COLOR_MODE" ]] && [[ "$COLOR_MODE" -ge 8 ]]; then
		BOLD="\x1b[1m"; RESET="\x1b[0m";
	fi
fi


OK=true;
for name in *.sh; do
	if [[ "$name" == __* ]]; then
		continue;
	fi

	echo -e "$BOLD[.] testing $name $RESET";
	bash "$name";

	if [[ "$?" != "0" ]]; then
		OK=false;
		echo -e "$BOLD[-] test failed! $RESET";
	else
		echo -e "$BOLD[~] test success! $RESET";
	fi
done

if [[ "$OK" == "true" ]]; then
	echo -e "$BOLD[+] all tests success! $RESET";
else
	echo -e "$BOLD[-] test failed! $RESET";
	exit 1;
fi
