#!/bin/bash

ambiente="$1"
source "$PREFIX/etc/fap25/config.conf"

folder="$HOMOLOG_PATH"
if [[ "$ambiente" == "PROD" ]]; then
  folder="$CAPX_PROD_PATH"
fi

# Inicia o script
capx_csv="$CAPX_CSV_FILE"
declare -A capxTitulo
declare -A capxAtriz

# Lê o CSV e armazena os dados em arrays associativos
while IFS=',' read -r capxId clipeId titulo atriz; do
  capxTitulo["$capxId#$clipeId"]="$titulo"
  capxAtriz["$capxId#$clipeId"]="$atriz"
done < "$capx_csv"

# Processa todos os arquivos no diretório
for filepath in "$folder"/*.mp4; do
  filename=$(basename "$filepath")

  if [[ "$filename" =~ ^CAPx#([0-9]{2})\ Clipe#([0-9]{2})\.mp4$ ]]; then
    capxId="${BASH_REMATCH[1]}"
    clipeId="${BASH_REMATCH[2]}"
    capxKey="$capxId#$clipeId"

    atriz="${capxAtriz[$capxKey]}"
    titulo="${capxTitulo[$capxKey]}"

    # Calcula mês e ano
    mes=$(( (10#$capxId - 1) % 12 + 1 ))
    ano=$((1990 + (10#$capxId - 1) / 12))
    hora_base=12

    hora=$((hora_base + $((10#$clipeId)) / 60))
    minuto=$(($((10#$clipeId)) % 60))

    # Formata os metadados
    title="$atriz @ $titulo #$clipeId"
    date="${ano}:$(printf "%02d" "$mes"):01 $hora:$(printf "%02d" "$minuto"):00"

     exiftool -q \
          -overwrite_original_in_place \
          "-Title=$title" \
          "-Copyright=@whitesanderson" \
          "-DateTimeOriginal=$date" \
          "-CreateDate=$date" \
          "-ModifyDate=$date" \
          "-FileModifyDate=$date" \
          "$filepath"

     printf "%-25s %s => %s\n" "$filename" "Metadados atualizados" "$date"
  fi
done
