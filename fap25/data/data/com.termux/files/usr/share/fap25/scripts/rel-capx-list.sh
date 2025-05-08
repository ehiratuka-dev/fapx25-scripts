#!/bin/bash

ambiente="$1"
source "$PREFIX/etc/fap25/config.conf"

folder="$HOMOLOG_PATH"
if [[ "$ambiente" == "PROD" ]]; then
  folder="$FAPX_PROD_PATH"
fi

# Inicia o script
exiftool -T -Filename -Title -ModifyDate "$folder" | \
awk -F'\t' '
BEGIN {
    printf "%-25s %-55s %-20s\n", "Arquivo", "Título", "Data"
    printf "%-25s %-55s %-20s\n", "-------------------------", "-------------------------------------------------------", "--------------------"
}
{
    printf "%-25s %-55s %-20s\n", $1, $2, $3
}'
