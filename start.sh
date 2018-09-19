#!/bin/bash
set -e

cd /opt/solr

DIR=$(pwd)
COMMAND=${1}
PORT=8983
INDEX_NAME="k-search"

## The amount of RAM reserved to the JVM for SOLR
SOLR_MEMORY=${SOLR_MEMORY:-512m}

## SIGTERM-handler, used when container is requested to be stopped
term_handler() {
  exec /opt/solr/bin/solr stop -p ${PORT} -s "${DIR}/${INDEX_NAME}"
  exit 143; # 128 + 15 -- SIGTERM
}

## setup handlers for kill the last background process and execute the specified handler
trap 'kill ${!}; term_handler' SIGTERM

echo "K-Search Engine, based on SOLR ${SOLR_VERSION}."

case "${COMMAND}" in
    'start')
        echo "Updating file permissions"
        chown "${SOLR_UID}:${SOLR_GID}" "${DIR}/${INDEX_NAME}" --recursive
        echo "Starting K-Search Engine..."
	# FIXME: Force temporary used to allow starting as privileged user
        exec ./bin/solr start -force -f -p ${PORT} -s "${DIR}/${INDEX_NAME}" -m "${SOLR_MEMORY}"
    ;;
    'optimize')
        echo "Optimizing the index..."
        exec curl "http://localhost:${PORT}/solr/${INDEX_NAME}/update?optimize=true&maxSegments=1&waitFlush=true"
    ;;
    *)
        echo "Available commands"
        echo "- start: starts an instance on port 8983"
        echo "- optimize: perform index optimization on a running instance"
        echo "- help: output this message"
   ;;
esac
