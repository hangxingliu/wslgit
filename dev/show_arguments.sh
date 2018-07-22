#!/usr/bin/env bash

i=1;
printf "arguments: {\n";

for argument in "$@"; do
	printf "\t%d: \"%s\"\n" "$i" "$argument";
	i=$(($i+1))
done

printf "}\n";