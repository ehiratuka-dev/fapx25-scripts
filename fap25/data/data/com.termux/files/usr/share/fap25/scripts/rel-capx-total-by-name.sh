#!/bin/bash

ambiente="$1"
source "$PREFIX/etc/fap25/config.conf"

folder="$HOMOLOG_PATH"
if [[ "$ambiente" == "PROD" ]]; then
  folder="$FAPX_PROD_PATH"
fi

# Inicia o script
awk -F',' '{
    n = split($4, names, /; /)
    for (i = 1; i <= n; i++) count[names[i]]++
} END {
    for (name in count) printf "%d\t%s\n", count[name], name
}' $CAPX_CSV_FILE | sort -nr | awk -F'\t' '
BEGIN {
    printf "%-25s %5s\n", "Atriz", "Total"
    printf "%-25s %5s\n", "-------------------------", "-----"
}
{
    printf "%-25s %5d\n", $2, $1
}'
