#!/bin/bash
set -e

cd /opt/solr

DIR=$(pwd)
CORE="k-search"
COMMAND=${1}
PORT=8983

## The amount of RAM reserved to the JVM for SOLR
SOLR_MEMORY=${SOLR_MEMORY:-512m}

## SIGTERM-handler, used when container is requested to be stopped
term_handler() {
  exec /opt/solr/bin/solr stop -p ${PORT} -s "${DIR}/${CORE}"
  exit 143; # 128 + 15 -- SIGTERM
}

## setup handlers for kill the last background process and execute the specified handler
trap 'kill ${!}; term_handler' SIGTERM

echo "K-Search Engine, based on SOLR ${SOLR_VERSION}."

case "${COMMAND}" in
    'start')
        echo "Starting K-Search Engine..."
        exec ./bin/solr start -f -p ${PORT} -s "${DIR}/${INDEX_NAME}" -m ${SOLR_MEMORY}
    ;;
    'optimize')
        echo "Optimizing the index..."
        exec curl "http://localhost:${PORT}/solr/${INDEX_NAME}/update?optimize=true&maxSegments=1&waitFlush=true"
    ;;
    *)
        echo "Starting K-Search Engine..."
        exec ./bin/solr start -f -p ${PORT} -s "${DIR}/${INDEX_NAME}" -m ${SOLR_MEMORY}
   ;;
esac