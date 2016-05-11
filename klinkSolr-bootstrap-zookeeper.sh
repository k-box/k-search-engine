#! /bin/bash

DIR=$(pwd)

KLINK_SOLR_BOOTSTRAP_ZOOKEEPER_HOSTNAME=${KLINK_SOLR_BOOTSTRAP_ZOOKEEPER_HOSTNAME:-localhost:2181}

KLINK_SOLR_BOOTSTRAP_FLAG=${KLINK_SOLR_BOOTSTRAP_FLAG:-${DIR}/solr-cloud/bootstrapped.flag}

rm -f $KLINK_SOLR_BOOTSTRAP_FLAG &&
server/scripts/cloud-scripts/zkcli.sh -zkhost ${KLINK_SOLR_BOOTSTRAP_ZOOKEEPER_HOSTNAME} -cmd bootstrap -solrhome ${DIR}/solr-cloud &&
touch $KLINK_SOLR_BOOTSTRAP_FLAG