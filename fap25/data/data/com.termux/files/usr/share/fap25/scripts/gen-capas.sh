#!/bin/bash

ambiente="$1"
source "$PREFIX/etc/fap25/config.conf"

folder="$HOMOLOG_PATH"
if [[ "$ambiente" == "PROD" ]]; then
  folder="$FAPX_PROD_PATH"
fi

# Inicia o script
shopt -s nullglob

for file in "$folder"/*.jpg; do
    filename=$(basename "$file")
    if [[ "$filename" =~ ^(.+)_(.+)_(.+)_(.+)\.jpg$ ]]; then
        xx="${BASH_REMATCH[1]}"

        novoNome="$xx Capa.jpg"
        novoCaminho="$folder/$novoNome"

        exiftool -q -overwrite_original -All= "$file"
        mv "$file" "$novoCaminho"

        printf "%-25s %s\n" "$novoNome" "Capas atualizadas"
    fi
done
