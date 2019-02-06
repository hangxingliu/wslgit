#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
pushd "$DIR";


# new_arguments;
i=0;
for argument in "$@"; do
	new_arguments[$i]="($argument)";
	i=$(($i+1));
done

# new_arguments2 (exclude first)
i=0;
for argument in "${@:2}"; do
	new_arguments2[$i]="($argument)";
	i=$(($i+1));
done

bash ./show-arguments.sh "${new_arguments[@]}";
bash ./show-arguments.sh "${new_arguments2[@]}";

