#!/bin/bash

ambiente="$1"
folder="/storage/emulated/0/Pictures/FAPx#Current"

if [[ "$ambiente" == "PROD" ]]; then
  folder="/storage/emulated/0/Pictures/FAPx#Current"
fi

# Inicia o script
awk -F',' '{
    n = split($4, names, /; /)
    for (i = 1; i <= n; i++) count[names[i]]++
} END {
    for (name in count) printf "%d\t%s\n", count[name], name
}' scripts/capx.csv | sort -nr | awk -F'\t' '
BEGIN {
    printf "%-25s %5s\n", "Atriz", "Total"
    printf "%-25s %5s\n", "-------------------------", "-----"
}
{
    printf "%-25s %5d\n", $2, $1
}'
