#!/bin/bash

PASTA_BASE="storage/pictures"
PASTA_VISIVEL="FAPx#25"
PASTA_OCULTA=".FAPx#25"

# Caminhos completos
DIR_VISIVEL="$PASTA_BASE/$PASTA_VISIVEL"
DIR_OCULTO="$PASTA_BASE/$PASTA_OCULTA"
ARQ_NOMEDIA="$DIR_OCULTO/.nomedia"

# Se a pasta visível existir
if [ -d "$DIR_VISIVEL" ]; then
    touch "$DIR_VISIVEL/.nomedia"
    mv "$DIR_VISIVEL" "$DIR_OCULTO"
    echo "FAPx#25 agora está oculto"
# Se a pasta oculta existir
elif [ -d "$DIR_OCULTO" ]; then
    rm -f "$ARQ_NOMEDIA"
    mv "$DIR_OCULTO" "$DIR_VISIVEL"
    echo "FAPx#25 agora está ativo"
else
    echo "Nenhuma das pastas existe."
fi
