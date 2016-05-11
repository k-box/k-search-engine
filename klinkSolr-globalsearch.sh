#!/bin/bash

cd /opt/solr

DIR=$(pwd)
PORT=8983
ZOOKEEPERDIR="/opt/zookeeper"
KLINK_SOLR_MEMORY=${KLINK_SOLR_MEMORY:-512m}
KLINK_SOLR_BOOTSTRAP_FLAG=${KLINK_SOLR_BOOTSTRAP_FLAG:-${DIR}/solr-cloud/bootstrapped.flag}
# KLINK_SOLR_BOOTSTRAP_ENABLE: {Y|N}
# defines if solr should attempt to boostrap zookeeper the first time it is started
KLINK_SOLR_BOOTSTRAP_ENABLE=${KLINK_SOLR_BOOTSTRAP_ENABLE:-N}

# Reads solr host name assuming that zookeeper is configured on this same host
function zk2myhost () {
    ZOOKEEPERPORT=$(cat ${ZOOKEEPERDIR}/conf/zoo.cfg | grep '^clientPort.*=' | awk -F= '{print $2}')
    ZOOKEEPERID=$(cat ${ZOOKEEPERDIR}/data/myid)
    echo $(grep "^server.${ZOOKEEPERID}" ${ZOOKEEPERDIR}/conf/zoo.cfg | sed "s@server.*=\([^:]*\).*@\1@")
}

function zk2zkhosts () {
    ZOOKEEPERPORT=$(cat ${ZOOKEEPERDIR}/conf/zoo.cfg | grep '^clientPort.*=' | awk -F= '{print $2}')
    local zkh=""
    for SERVER in $(grep "^server.*=" ${ZOOKEEPERDIR}/conf/zoo.cfg) ; do
      zkh=${zkh},$(echo ${SERVER} | awk -F= '{print $2}' | awk -F: '{print $1}'):${ZOOKEEPERPORT}
    done
    zkh=${zkh:1}
    echo $zkh
}

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
        if [ -z "${KLINK_SOLR_MYHOST}" ]; then KLINK_SOLR_MYHOST=$(zk2myhost); fi
        if [ -z "${KLINK_SOLR_ZKHOSTS}" ]; then KLINK_SOLR_ZKHOSTS=$(zk2zkhosts); fi
        
        
        if [ -z "${KLINK_SOLR_ZKHOSTS}" ] ; then
            echo "Error in Zookeeper KLINK_SOLR_ZKHOSTS configuration!!"
            exit -1
        fi

        init_empty_dir /opt/solr/solr-cloud/klink-public/data /opt/solr/solr-cloud/klink-public/data.tar.xz &&

        ./bin/solr $1 -p ${PORT} -s "${DIR}/solr-cloud" -c -z ${KLINK_SOLR_ZKHOSTS} -h ${KLINK_SOLR_MYHOST} -memory ${KLINK_SOLR_MEMORY}
    ;;

    'start-foreground')
        if [ -z "${KLINK_SOLR_MYHOST}" ]; then KLINK_SOLR_MYHOST=$(zk2myhost); fi
        if [ -z "${KLINK_SOLR_ZKHOSTS}" ]; then KLINK_SOLR_ZKHOSTS=$(zk2zkhosts); fi
        
        if [ -z "${KLINK_SOLR_ZKHOSTS}" ] ; then
            echo "Error in Zookeeper KLINK_SOLR_ZKHOSTS configuration!!"
            exit -1
        fi

        if [ "$KLINK_SOLR_BOOTSTRAP_ENABLE" = "Y" -a ! -f "$KLINK_SOLR_BOOTSTRAP_FLAG" ]; then
            ./klinkSolr-bootstrap-zookeeper.sh
        fi

        init_empty_dir /opt/solr/solr-cloud/klink-public/data /opt/solr/solr-cloud/klink-public/data.tar.xz &&

        exec ./bin/solr start -f -p ${PORT} -s "${DIR}/solr-cloud" -c -z ${KLINK_SOLR_ZKHOSTS} -h ${KLINK_SOLR_MYHOST} -memory ${KLINK_SOLR_MEMORY}
    ;;
 
    'stop')
        ./bin/solr $1 -p ${PORT} -s "${DIR}/solr-cloud"
    ;;

    *)
        echo "$0: Command $1 not found for (start|stop)"
    ;;
esac
