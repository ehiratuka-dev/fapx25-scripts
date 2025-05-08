#!/bin/bash

ambiente="$1"
source "$PREFIX/etc/fap25/config.conf"

folder="$HOMOLOG_PATH"
if [[ "$ambiente" == "PROD" ]]; then
  folder="$FAPX_PROD_PATH"
fi

# Inicia o script
outputRoot="$folder"

readarray -t files < <(find "$folder" -maxdepth 1 -type f -name "*.mp4" | sort)

for inputFileFullPath in "${files[@]}"; do
  fileName="$(basename "$inputFileFullPath")"
  if [[ "$fileName" =~ ^(GIFx|RECx|R25x)#(.+)$ ]]; then
    fileName="$(basename "$inputFileFullPath")"
    fileNameNoExt="${fileName%.*}"
    outputDir="$outputRoot/$fileNameNoExt"

    mkdir -p "$outputDir"

    ffmpeg -loglevel error -i "$inputFileFullPath" -q:v 0 "$outputDir/${fileNameNoExt} Quadro#%03d.jpg"

    if [[ $? -eq 0 ]]; then
        printf "%-25s %s\n" "$fileName" "Quadros gerados"
    else
        echo "$fileName => Erro ao gerar quadros."
    fi
  fi
done
