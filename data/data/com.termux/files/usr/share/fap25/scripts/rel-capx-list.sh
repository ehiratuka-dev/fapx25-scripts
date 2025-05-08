#!/bin/bash

ambiente="$1"
folder="/storage/emulated/0/Pictures/FAPx#Current"

if [[ "$ambiente" == "PROD" ]]; then
  folder="/storage/emulated/0/Pictures/FAPx#Current"
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
