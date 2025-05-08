#!/bin/bash

ambiente="$1"
source "$PREFIX/etc/fap25/config.conf"

folder="$HOMOLOG_PATH"
if [[ "$ambiente" == "PROD" ]]; then
  folder="$FAPX_PROD_PATH"
fi

# Inicia o script
declare -A grupoContadores

find "$folder" -maxdepth 1 -type f -name "*.jpg" | sort | while IFS= read -r filePath; do
    fileName="$(basename "$filePath")"
    descricao=""
    prefixoGrupo=""

    if [[ "$fileName" =~ ^GIFx#([0-9]{2})\ Quadro#([0-9]{3})\.jpg$ ]]; then
        indice="${BASH_REMATCH[1]}"
        quadro="${BASH_REMATCH[2]}"
        descricao="Obtido do Quadro #$quadro"
        prefixoGrupo="GIFx#$indice"
    elif [[ "$fileName" =~ ^RECx#([0-9]{2})\ Clipe#([0-9]{2})\ Quadro#([0-9]{3})\.jpg$ ]]; then
        indice="${BASH_REMATCH[1]}"
        clipe="${BASH_REMATCH[2]}"
        quadro="${BASH_REMATCH[3]}"
        descricao="Obtido do Quadro #$quadro"
        prefixoGrupo="RECx#$indice Clipe#$clipe"
    elif [[ "$fileName" =~ ^R25x#([0-9]{2})\ Clipe#([0-9]{2})\ Quadro#([0-9]{3})\.jpg$ ]]; then
        indice="${BASH_REMATCH[1]}"
        clipe="${BASH_REMATCH[2]}"
        quadro="${BASH_REMATCH[3]}"
        descricao="Obtido do Quadro #$quadro"
        prefixoGrupo="R25x#$indice Clipe#$clipe"
    fi

    if [[ -n "$descricao" ]]; then
        if [[ -z "${grupoContadores["$prefixoGrupo"]}" ]]; then
            grupoContadores["$prefixoGrupo"]=1
        else
            grupoContadores["$prefixoGrupo"]=$((grupoContadores["$prefixoGrupo"] + 1))
        fi
        contador="${grupoContadores["$prefixoGrupo"]}"
        contadorFormatado=$(printf "%02d" "$contador")

        exiftool -q -overwrite_original -Description="$descricao" -ImageDescription="$descricao" "$filePath"

        novoNome="$prefixoGrupo Hot#$contadorFormatado.jpg"
        novoCaminho="$(dirname "$filePath")/$novoNome"
        mv "$filePath" "$novoCaminho"

        printf "%-25s %s => %s\n" "$fileName" "Destaques atualizados" "$descricao"
    # else
        # echo "$fileName => Sem correspondência."
    fi
done
