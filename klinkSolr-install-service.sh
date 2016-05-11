#! /bin/bash

BASEDIR=$(pwd)

case "$1" in
    'globalsearch' | 'localsearch')
        # # Adding Search Services
        # echo "Installing SOLR Service: ${1}"
        # sudo cp ${BASEDIR}/solr-init.d/solr_${1} /etc/init.d/solr_${1}
        # sudo chmod +x /etc/init.d/solr_${1}
        # sudo update-rc.d solr_${1} defaults
    ;;
    *)
        echo "$0: the provide ServiceName $1 not found! Usage: $0 [localsearch|globalsearch]"
   ;;
esac
