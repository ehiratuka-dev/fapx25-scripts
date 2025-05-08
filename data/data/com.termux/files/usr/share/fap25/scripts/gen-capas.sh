#!/bin/bash

ambiente="$1"
folder="/storage/emulated/0/Pictures/FAPx#Current"

if [[ "$ambiente" == "PROD" ]]; then
  folder="/storage/emulated/0/Pictures/FAPx#Current"
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
