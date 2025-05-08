#!/bin/bash

ambiente="$1"
source "$PREFIX/etc/fap25/config.conf"

folder="$HOMOLOG_PATH"
if [[ "$ambiente" == "PROD" ]]; then
  folder="$FAPX_PROD_PATH"
fi

# Inicia o script
profiles_csv="$PROFILE_CSV_FILE"

# Lê o CSV e carrega perfis em um array associativo
declare -A profileNames
while IFS=',' read -r tipo id nome; do
  [[ "$tipo" == "Tipo" ]] && continue  # Ignora cabeçalho
  profileNames["$tipo#$id"]="$nome"
done < "$profiles_csv"

# Processa os arquivos no diretório
find "$folder" -maxdepth 1 -type f | sort | while IFS= read -r filePath; do
  fileName="$(basename "$filePath")"
  errors=""

  ano=""; mes=""; 
  minutos=""; segundos="" 
  horaBRZ=""; horaUTC=""; horaGMT=""
  recTitle=""; title=""; keywords=""

  if [[ "$fileName" =~ ^(GIFx|RECx|R25x|UnderAI|Arquivo)#([0-9]{2})(.+)$ ]]; then
    recType="${BASH_REMATCH[1]}"
    recId="${BASH_REMATCH[2]}"
    especs="${BASH_REMATCH[3]}"

    if [[ "$recType" == "UnderAI" ]]; then
      ano="1999"
      mes="01"
      minutos="$recId"
      recTitle="$recType#$recId"
    elif [[ "$recType" == "Arquivo" ]]; then
      mes=$(printf "%02d" $(( (10#$recId - 1) % 12 + 1 )))
      ano=$((1980 + (10#$recId - 1) / 12))
      recTitle="$recType#$recId"
    elif [[ "$recType" == "GIFx" ]]; then
      ano="2010"
      mes="$recId"
      minutos="00"
      recTitle="$recType#$recId"
    elif [[ "$recType" =~ ^RECx|R25x$ ]]; then
      if [[ "$especs" =~ ^\ Clipe#([0-9]{2})(.+)$ ]]; then
        clipeId="${BASH_REMATCH[1]}"
        especs="${BASH_REMATCH[2]}"

        if [[ "$recType" == "RECx" && "$recId" =~ ^0[1-7]$ ]]; then
          ano="2000"
          mes="$recId"
          minutos="$clipeId"
          recTitle="$recType#$recId Clipe#$clipeId"
        elif [[ "$recType" == "RECx" && "$recId" =~ ^(1[0-9]|0[8-9])$ ]]; then
          ano="2001"
          mes=$(printf "%02d" $((10#$recId - 7)))
          minutos="$clipeId"
          recTitle="$recType#$recId Clipe#$clipeId"
        elif [[ "$recType" == "R25x" ]]; then
          ano="2002"
          mes="$recId"
          minutos="$clipeId"
          recTitle="$recType#$recId Clipe#$clipeId"
        else
          errors="Padrão de REC_ID não reconhecido para os tipos RECx ou R25x"
        fi
      else
        errors="Clipe#999 é obrigatório para oa tipos RECx ou R25x"
      fi
    fi

    profileKey="$recType#$recId"
    profileName="${profileNames[$profileKey]}"
    if [[ -z "$errors" && -n "$profileName" ]]; then

      profileSlug=$(echo "$profileName" | tr '[:upper:]' '[:lower:]' | tr -d '.' | tr ' ' '-')
      recTypeSlug=$(echo "$recType" | tr '[:upper:]' '[:lower:]')
      if [[ "$especs" =~ ^\ Hot#([0-9]{2})(.+)$ ]]; then
        hotId="${BASH_REMATCH[1]}"
        especs="${BASH_REMATCH[2]}"
        segundos="$hotId"

        profileKey="$recType#$recId"
        profileName="${profileNames[$profileKey]}"
        title="$profileName @ $recTitle Hot#$hotId"
        keywords="@$profileSlug; #$recTypeSlug"
      elif [[ "$especs" =~ ^\ Capa(.+)$ ]]; then
        especs="${BASH_REMATCH[1]}"
        segundos="59"
        title="$profileName @ $recTitle Capa"
        keywords="@$profileSlug; #$recTypeSlug"
      elif [[ "$especs" == ".mp4" ]]; then
        segundos="00"
        title="$profileName @ $recTitle"
        keywords="@$profileSlug; #$recTypeSlug"
      elif [[ "$recType" == "UnderAI" ]]; then
        if [[ "$especs" =~ ^\ (Nude|Social)(.+)$ ]]; then
          nudeAiType="${BASH_REMATCH[1]}"
          especs="${BASH_REMATCH[2]}"

          if [[ "$nudeAiType" == "Nude" ]]; then
            segundos="02"
          elif [[ "$nudeAiType" == "Social" ]]; then
            segundos="01"
          else
            errors="Sufixo de UnderAI deve ser Nude ou Social"
          fi

          title="$profileName @ $recTitle $nudeAiType"
          keywords="@$profileSlug; #$recTypeSlug"
        fi
      elif [[ "$recType" == "Arquivo" ]]; then
        if [[ "$especs" =~ ^\ Foto#([0-9]{2})(.+)$ ]]; then
          fotoId="${BASH_REMATCH[1]}"
          especs="${BASH_REMATCH[2]}"
          minutos="$fotoId"
          segundos="00"

          profileKey="$recType#$recId"
          profileName="${profileNames[$profileKey]}"
          title="$profileName @ $recTitle Foto#$fotoId"
          keywords="@$profileSlug; #$recTypeSlug"
        fi
      else
        errors="Sufixo de clipe devem ser Hot#99.jpg, Capa.jpg ou .mp4"
      fi

    else
      errors="Profile não encontrado para a chave $recType#$recId"
    fi

    if [[ -z "$errors" && -n "$ano" && -n "$mes" && -n "$minutos" && -n "$segundos" && -n "$title" && -n "$keywords" ]]; then
      if [[ "$mes" == "01" || "$mes" == "02" ]]; then
        horaBRZ="11:$minutos:$segundos"
        horaUTC="14:$minutos:$segundos"
        horaGMT="12:$minutos:$segundos"
      else
        horaBRZ="12:$minutos:$segundos"
        horaUTC="15:$minutos:$segundos"
        horaGMT="12:$minutos:$segundos"
      fi

      dataBRZ="$ano:$mes:01 $horaBRZ"
      dataUTC="$ano:$mes:01 $horaUTC"
      dataGMT="$ano:$mes:01 $horaGMT"

      if [[ "$especs" == ".mp4" ]]; then
        exiftool -q \
          -overwrite_original_in_place \
          "-Title=$title" \
          "-Copyright=@whitesanderson" \
          "-Keywords=$keywords" \
          "-DateTimeOriginal=$dataUTC" \
          "-CreateDate=$dataUTC" \
          "-ModifyDate=$dataUTC" \
          "-FileModifyDate=$dataGMT" \
          "$filePath"
      else
        exiftool -q \
          -overwrite_original_in_place \
          "-Title=$title" \
          "-Copyright=@whitesanderson" \
          "-Keywords=$keywords" \
          "-DateTimeOriginal=$dataGMT" \
          "-CreateDate=$dataGMT" \
          "-ModifyDate=$dataGMT" \
          "-FileModifyDate=$dataGMT" \
          "$filePath"
      fi 

      printf "%-25s %s => %s\n" "$fileName" "Metadados atualizados" "$dataGMT"
    # else
      # if [[ -z "$errors" ]]; then
      #   printf "%-25s | One or more properties missing\n" "$fileName"
      # else
      #   echo "$errors <= $fileName"
      # fi
    fi
  fi

done

