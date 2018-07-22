#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
pushd "$DIR";


# new_arguments;
i=0;
for argument in "$@"; do
	new_arguments[$i]="($argument)";
	i=$(($i+1));
done

bash ./show_arguments.sh "${new_arguments[@]}";
