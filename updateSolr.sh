#! /usr/bin/env bash
# Author: Emanuele Panzeri <thepanz@gmail.com>
# Usage:
#  updateSolr.sh [localsearch]
#

# Remove undesirable side effects of CDPATH variable
unset CDPATH
# Change current working directory to the directory contains this script
cd "$( dirname "${BASH_SOURCE[0]}" )"

#### internal variables ####

BASEDIR=$(pwd)
LOGDIR=${BASEDIR}
SERVERDIR=${BASEDIR}/server
TEMPFOLDER=${BASEDIR}/temp

#### application-bound variables ####

KLINK_SETUP_DOWNLOADFOLDER=${KLINK_SETUP_DOWNLOADFOLDER:-${BASEDIR}/downloads}
KLINK_SOLR_VERSION=${KLINK_SOLR_VERSION:-5.5.3}
KLINK_SOLR_MD5_LINK=${KLINK_SOLR_MD5_LINK:-https://archive.apache.org/dist/lucene/solr/${KLINK_SOLR_VERSION}/solr-${KLINK_SOLR_VERSION}.zip.md5}

#### end variables ####

. bash-utils/helper.sh

function solr_download() {
    cd ${TEMPFOLDER}

    helper_show_partial_message "Downloading SOLR (${KLINK_SOLR_VERSION}) ... "
    
    if helper_file_exists "${KLINK_SETUP_DOWNLOADFOLDER}/solr-${KLINK_SOLR_VERSION}.zip.md5"; then
        pushd ${KLINK_SETUP_DOWNLOADFOLDER} >> ${LOGDIR}/updateSolr.log 2>> ${LOGDIR}/updateSolr.error &&
        md5sum -c solr-${KLINK_SOLR_VERSION}.zip.md5 >> ${LOGDIR}/updateSolr.log 2>> ${LOGDIR}/updateSolr.error &&
        popd >> ${LOGDIR}/updateSolr.log 2>> ${LOGDIR}/updateSolr.error

        if [ $? -ne "0" ]; then
            # The file is not right! Remove Dir and all the downloaded file
            rm -fr ${TEMPFOLDER}/solr-${KLINK_SOLR_VERSION} &&
            rm ${KLINK_SETUP_DOWNLOADFOLDER}/solr-${KLINK_SOLR_VERSION}.zip &&
            rm ${KLINK_SETUP_DOWNLOADFOLDER}/solr-${KLINK_SOLR_VERSION}.zip.md5
        else
            helper_show_warning "Skipped"
            return 0
        fi
    fi
    SOLR_LINK=$(helper_apache_get_mirror "lucene/solr/${KLINK_SOLR_VERSION}/solr-${KLINK_SOLR_VERSION}.zip")
    
    helper_show_message ""
    helper_show_partial_message " - Using Mirror: "
    helper_show_notice ${SOLR_LINK}
    helper_show_partial_message " - Downloading ... "

    pushd ${KLINK_SETUP_DOWNLOADFOLDER} >> ${LOGDIR}/updateSolr.log 2>> ${LOGDIR}/updateSolr.error
    curl ${SOLR_LINK} --retry 10 --silent --output solr-${KLINK_SOLR_VERSION}.zip >> ${LOGDIR}/updateSolr.log 2>> ${LOGDIR}/updateSolr.error &&
    curl ${KLINK_SOLR_MD5_LINK} --retry 10 --silent --output solr-${KLINK_SOLR_VERSION}.zip.md5 >> ${LOGDIR}/updateSolr.log 2>> ${LOGDIR}/updateSolr.error &&
    md5sum -c solr-${KLINK_SOLR_VERSION}.zip.md5 >> ${LOGDIR}/updateSolr.log 2>> ${LOGDIR}/updateSolr.error &&
    popd >> ${LOGDIR}/updateSolr.log 2>> ${LOGDIR}/updateSolr.error

    if [ $? -ne "0" ]; then
        helper_show_error "Error"
        helper_show_error " - Error while downloading SOLR and checking solr versions!"
        return 1
    fi
    helper_show_success "Done"
    return 0
}


function solr_extract_files() {
    cd ${TEMPFOLDER}
    helper_show_partial_message "Extracting SOLR files ... "
    if ! helper_directory_exists "${TEMPFOLDER}/solr-${KLINK_SOLR_VERSION}" ; then
        unzip -qq -o ${KLINK_SETUP_DOWNLOADFOLDER}/solr-${KLINK_SOLR_VERSION}.zip >> ${LOGDIR}/updateSolr.log 2>> ${LOGDIR}/updateSolr.error
        if [ $? -ne "0" ]; then
            helper_show_error "Error"
            helper_show_error " - Error while Extracting SOLR"
            return 1
        else
            helper_show_success "Done"
        fi
    else
        helper_show_warning "Skipped"
    fi
    return 0
}

function solr_deploy() {
    helper_show_partial_message "Deploy SOLR folders Context... "
    cd ${TEMPFOLDER}/solr-${KLINK_SOLR_VERSION}
    cp --force --recursive --target-directory=../../ bin contrib dist server
    helper_show_success "Done"

    helper_show_partial_message "Deploy Jetty server-override configurations... "
    cp --force --recursive ${BASEDIR}/server-override/* ${SERVERDIR}/
    if [ $? -ne "0" ]; then
        helper_show_error "Error"
        return 1
    fi
    helper_show_success "Done"

    if helper_file_exists "${BASEDIR}/solr.in.sh" ; then
        helper_show_partial_message "Removing overrided file "
        helper_show_partial_notice "bin/solr.in.sh"
        helper_show_partial_message " ... "
        rm -fr ${BASEDIR}/bin/solr.in.sh
        if [ $? -ne "0" ]; then
            helper_show_error "Error"
            return 1
        fi
        helper_show_success "Done"
    fi

    return 0
}

function solr_remove_temporary() {
    helper_show_partial_message "Removing temporary files: "
    rm -fr  ${TEMPFOLDER}
    helper_show_success "Done"
}

cat /dev/null > ${LOGDIR}/updateSolr.error
cat /dev/null > ${LOGDIR}/updateSolr.log
mkdir -p ${TEMPFOLDER}
mkdir -p ${KLINK_SETUP_DOWNLOADFOLDER}

# helper_show_header_big "SOLR Install/Update"

if ! solr_download; then
    helper_show_error " Check errors in ${LOGDIR}/updateSolr.error ${LOGDIR}/updateSolr.log"
    exit 1
fi

if ! solr_extract_files; then
    helper_show_error " Check errors in ${LOGDIR}/updateSolr.error ${LOGDIR}/updateSolr.log"
    exit 1
fi

if ! solr_deploy; then
    helper_show_error " Check errors in ${LOGDIR}/updateSolr.error ${LOGDIR}/updateSolr.log"
    exit 1
fi

if ! solr_remove_temporary; then
    helper_show_error " Check errors in ${LOGDIR}/updateSolr.error ${LOGDIR}/updateSolr.log"
    exit 1
fi

exit 0
