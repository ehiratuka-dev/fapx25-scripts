#!/bin/bash

# Verifica se os dois argumentos foram fornecidos
if [ "$#" -ne 2 ]; then
  echo "Uso: $0 <capx> <clipe>"
  exit 1
fi

capx="$1"
clipe="$2"

# Define os caminhos com base nas variáveis
input_file="PC-do-Edu:Users/ehiratuka/Downloads/CAPx#${capx} Clipe#${clipe}.txt"
local_file="storage/pictures/CAPx#${capx} Clipe#${clipe}.txt"
output_file="storage/pictures/FAPx#Current/CAPx#${capx} Clipe#${clipe}.mp4"

# Copia o arquivo do rclone
rclone copy "$input_file" storage/pictures

curl_command=$(<"$local_file")
output_file="$output_file"

# Extrai a URL
url=$(echo "$curl_command" | grep -oP "curl\s+'\K[^']+")

# Extrai headers -H
headers=$(echo "$curl_command" | grep -oP "(?<=-H\s)'[^']+'" | sed "s/^'//;s/'$//")

# Extrai cookies -b
cookie=$(echo "$curl_command" | grep -oP "(?<=-b\s)'[^']+'" | sed "s/^'//;s/'$//")
[[ -n "$cookie" ]] && headers+="
Cookie: $cookie"

# Monta os headers em uma única string compatível com ffmpeg
ffmpeg_headers=$(printf "%s\n" "$headers" | sed "s/^/    /")
ffmpeg_header_arg="-headers \$'$(printf "%s\n" "$headers" | sed "s/'/\\\\'/g" | sed 's/$/\\n/' | tr -d '\n')'"
ffmpeg_header_noarg="\$'$(printf "%s\n" "$headers" | sed "s/'/\\\\'/g" | sed 's/$/\\n/' | tr -d '\n')'"

# echo "Comando FFmpeg equivalente:"
# echo "ffmpeg $ffmpeg_header_arg -i '$url' -c copy $output_file"

# echo "ffmpeg -headers \"$ffmpeg_header_noarg\" -i \"$url\" -c copy \"$output_file\""
# ffmpeg -headers "$ffmpeg_header_noarg" -i "$url" -c copy "$output_file"

# Prepara string final para usar com -headers $'...'
ffmpeg_header_arg=$(printf "%s\n" "$headers" | sed "s/'/\\\\'/g" | sed 's/$/\\n/' | tr -d '\n')

# Executa ffmpeg
eval "ffmpeg -headers \$'$ffmpeg_header_arg' -i '$url' -c copy \"$output_file\""
