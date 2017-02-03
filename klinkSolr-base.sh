#!/bin/bash

cd /opt/solr

DIR=$(pwd)
COMMAND=${1}
PORT=${2}
CORE=${3}

KLINK_SOLR_MEMORY=${KLINK_SOLR_MEMORY:-512m}

case "${COMMAND}" in
    'start')
        exec ./bin/solr $1 -p ${PORT} -s "${DIR}/${CORE}" -m ${KLINK_SOLR_MEMORY}
    ;;
    'start-foreground')
        exec ./bin/solr start -f -p ${PORT} -s "${DIR}/${CORE}" -m ${KLINK_SOLR_MEMORY}
    ;;
    'stop')
        exec ./bin/solr stop -p ${PORT} -s "${DIR}/${CORE}"
    ;;
    'start-optimize-stop-start-foreground')
        exec ./bin/solr start -p ${PORT} -s "${DIR}/${CORE}" -m ${KLINK_SOLR_MEMORY}

        CORE_NAME="klink-private"
        if [ ${CORE} == "solr-cloud" ]; then
            CORE_NAME="klink-public"
        fi
        curl "http://localhost:${PORT}/solr/${CORE_NAME}/update?optimize=true&maxSegments=1&waitFlush=false"
        exec ./bin/solr stop -p ${PORT} -s "${DIR}/${CORE}"
        exec ./bin/solr start -f -p ${PORT} -s "${DIR}/${CORE}" -m ${KLINK_SOLR_MEMORY}
    ;;
    *)
        echo "$0: Command ${COMMAND} not found for (start|stop|start-foreground)"
   ;;
esac
