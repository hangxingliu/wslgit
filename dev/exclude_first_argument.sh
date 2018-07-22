#!/usr/bin/env bash

i=2;
printf "arguments: {\n";

for argument in "${@:2}"; do
	printf "\t%d: \"%s\"\n" "$i" "$argument";
	i=$(($i+1))
done

printf "}\n";