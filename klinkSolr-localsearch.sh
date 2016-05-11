#!/bin/bash

cd /opt/solr

DIR=$(pwd)
PORT=8984
KLINK_SOLR_MEMORY=${KLINK_SOLR_MEMORY:-512m}

function init_empty_dir() {
    local dir_to_init=$1
    local init_tar=$2

    if [ "$(ls -A $dir_to_init | grep -v '^\.gitkeep$' | grep -v '^\.gitignore$')" ]; then
        echo "Directory already inited: $(ls -A $dir_to_init)"
    else
        tar xf "$init_tar" -C "$dir_to_init"
        # && echo "Inited $dir_to_init with $init_tar" || echo "Could not init $dir_to_init with $init_tar"
    fi
}

case "$1" in
    'start')
        init_empty_dir /opt/solr/solr-private/klink-private/data /opt/solr/solr-private/klink-private/data.tar.xz &&
        ./bin/solr $1 -p ${PORT} -s "${DIR}/solr-private" -memory ${KLINK_SOLR_MEMORY}
    ;;
    'start-foreground')
        init_empty_dir /opt/solr/solr-private/klink-private/data /opt/solr/solr-private/klink-private/data.tar.xz &&
        exec ./bin/solr start -f -p ${PORT} -s "${DIR}/solr-private" -memory ${KLINK_SOLR_MEMORY}
    ;;
    'stop')
        ./bin/solr $1 -p ${PORT} -s "${DIR}/solr-private"
    ;;
    *)
        echo "$0: Command $1 not found for (start|stop)"
   ;;
esac
