#! /usr/bin/env bash
# Author: Emanuele Panzeri <thepanz@gmail.com>
# Usage:
#  updateSolr.sh [localsearch]
#
# Pass the "localsearch" string to the invocation to initialize the localsearch service

# Remove undesirable side effects of CDPATH variable
unset CDPATH
# Change current working directory to the directory contains this script
cd "$( dirname "${BASH_SOURCE[0]}" )"

#### internal variables ####

BASEDIR=$(pwd)
# LOGDIR=${BASEDIR}/logs
LOGDIR=${BASEDIR}
SERVERDIR=${BASEDIR}/server
TEMPFOLDER=${BASEDIR}/temp

#### application-bound variables ####

KLINK_SETUP_DOWNLOADFOLDER=${KLINK_SETUP_DOWNLOADFOLDER:-/opt/klink-downloads}
KLINK_SOLR_VERSION=${KLINK_SOLR_VERSION:-4.10.4}
KLINK_SOLR_LANGDETECT_VERSION=${KLINK_SOLR_LANGDETECT_VERSION:-03-03-2014}
KLINK_SOLR_LANGDETECT_LINK=${KLINK_SOLR_LANGDETECT_LINK:-http://language-detection.googlecode.com/git-history/packages/packages/langdetect-${KLINK_SOLR_LANGDETECT_VERSION}.zip}
KLINK_SOLR_MD5_LINK=${KLINK_SOLR_MD5_LINK:-https://archive.apache.org/dist/lucene/solr/${KLINK_SOLR_VERSION}/solr-${KLINK_SOLR_VERSION}.zip.md5}
KLINK_SOLR_SOLRBIN_LINK=${KLINK_SOLR_SOLRBIN_LINK:-https://raw.githubusercontent.com/apache/lucene-solr/branch_5x/solr/bin/solr}

#### end variables ####

. bash-utils/helper.sh

function solr_clear() {
  rm -fr ${BASEDIR}/solr-webapp/webapp
  rm -fr ${SERVERDIR}/webapps/solr.war
  rm -fr ${SERVERDIR}/solr-webapp/webapp
  rm -fr ${BASEDIR}/solr/contrib/extraction
  rm -fr ${BASEDIR}/solr/dist/solr-cell-*
  rm -fr ${BASEDIR}/solr/contrib/langid
  rm -fr ${BASEDIR}/solr/dist/solr-langid-*
  # rm -fr ${BASEDIR}/bin/
}

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

function langdetect_download() {
    helper_show_partial_message "Downloading LangDetect Lib (${KLINK_SOLR_LANGDETECT_VERSION}) ... "
    if ! helper_file_exists "${KLINK_SETUP_DOWNLOADFOLDER}/langdetect-${KLINK_SOLR_LANGDETECT_VERSION}.zip"; then
        pushd ${KLINK_SETUP_DOWNLOADFOLDER} >> ${LOGDIR}/updateSolr.log 2>> ${LOGDIR}/updateSolr.error &&
        curl ${KLINK_SOLR_LANGDETECT_LINK} --silent --output langdetect-${KLINK_SOLR_LANGDETECT_VERSION}.zip >> ${LOGDIR}/updateSolr.log 2>> ${LOGDIR}/updateSolr.error &&
        popd >> ${LOGDIR}/updateSolr.log 2>> ${LOGDIR}/updateSolr.error

        if [ $? -ne "0" ]; then
            helper_show_error "Error"
            helper_show_error " - Error while downloading LangDetect Lib!"
            return 1
        fi
        helper_show_success "Done"
    else
        helper_show_warning "Skipped"
    fi
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

function langdetect_extract_files() {
    cd ${TEMPFOLDER}
    helper_show_partial_message "Extracting Lang-Detect library ... "
    unzip -qq -o ${KLINK_SETUP_DOWNLOADFOLDER}/langdetect-${KLINK_SOLR_LANGDETECT_VERSION}.zip -d langdetect-${KLINK_SOLR_LANGDETECT_VERSION} >> ${LOGDIR}/updateSolr.log 2>> ${LOGDIR}/updateSolr.error
    if [ $? -ne "0" ]; then
        helper_show_error "Error"
        return 1
    fi
    helper_show_success "Done"
}

function langdetect_deploy() {
    # Library: Language Detect Libs
    helper_show_partial_message "Deploying Language Detection Libs ... "
    cp -r ${TEMPFOLDER}/solr-${KLINK_SOLR_VERSION}/dist/solr-langid-*   ${BASEDIR}/solr/dist/
    
    cp -r ${TEMPFOLDER}/solr-${KLINK_SOLR_VERSION}/contrib/langid ${BASEDIR}/solr/contrib/
    # Removing old Libraries for LangDetection
    rm -r ${BASEDIR}/solr/contrib/langid/lib/langdetect*.jar &&
    rm -r ${BASEDIR}/solr/contrib/langid/lib/jsonic*.jar &&
    cp -r ${TEMPFOLDER}/langdetect-${KLINK_SOLR_LANGDETECT_VERSION}/lib/langdetect.jar ${BASEDIR}/solr/contrib/langid/lib/ &&
    cp -r ${TEMPFOLDER}/langdetect-${KLINK_SOLR_LANGDETECT_VERSION}/lib/jsonic-*.jar   ${BASEDIR}/solr/contrib/langid/lib/

    # cp -r ${TEMPFOLDER}/langdetect-${KLINK_SOLR_VERSION}/lib/langdetect.jar ${BASEDIR}/solr-lib/langid/lib/
    # cp -r ${TEMPFOLDER}/solr-${KLINK_SOLR_VERSION}/example/lib/*     ${BASEDIR}/lib/

    if [ $? -ne "0" ]; then
        helper_show_error "Error"
        helper_show_error " - Error while Deploying files"
        return 1
    fi
    helper_show_success "Done"
}


function solr_deploy() {  
    helper_show_partial_message "Deploying Libraries ... "
    cp -r ${TEMPFOLDER}/solr-${KLINK_SOLR_VERSION}/example/start.jar ${SERVERDIR}/ &&
    cp -r ${TEMPFOLDER}/solr-${KLINK_SOLR_VERSION}/example/lib/*     ${SERVERDIR}/lib/
    if [ $? -ne "0" ]; then
        helper_show_error "Error"
        return 1
    fi
    helper_show_success "Done"

    helper_show_partial_message "Deploying Scripts and BIN folders ... "
    cp -r ${TEMPFOLDER}/solr-${KLINK_SOLR_VERSION}/example/scripts   ${SERVERDIR}/  &&
    cp -r ${TEMPFOLDER}/solr-${KLINK_SOLR_VERSION}/bin               ${BASEDIR}/
    if [ $? -ne "0" ]; then
        helper_show_error "Error"
        return 1
    fi
    helper_show_success "Done"
    
    helper_show_partial_notice "Deploying SOLR executable from 5.x branch ... "
    # Using executable from 5.x trunk, fixes the issue with SOLR-3619 (fixed in 4.10.x but NOT in 4.10.3??? WTF?)
    
    curl ${KLINK_SOLR_SOLRBIN_LINK} --silent --output ${BASEDIR}/bin/solr >> ${LOGDIR}/updateSolr.log 2>> ${LOGDIR}/updateSolr.error &&
    # patching solr foreground mode to run java using "exec"
    sed -i '/if.*$run_in_foreground.*true.*then/,/else/s/^\([[:blank:]]*\)\("$JAVA".*start.jar\)/\1exec \2/' ${BASEDIR}/bin/solr &&
    chmod +x ${BASEDIR}/bin/solr
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

    # Solr WAR
    helper_show_partial_message "Deploying SOLR.war ... "
    cp    ${TEMPFOLDER}/solr-${KLINK_SOLR_VERSION}/dist/solr-${KLINK_SOLR_VERSION}.war    ${SERVERDIR}/webapps/solr.war
        if [ $? -ne "0" ]; then
        helper_show_error "Error"
        return 1
    fi
    helper_show_success "Done"

    helper_show_partial_message "Deploying (pre-uncompressed) SOLR.war ... "
    rm -fr ${SERVERDIR}/solr-webapp/webapp &&
    mkdir -p ${SERVERDIR}/solr-webapp/webapp &&
    unzip -qq -o ${SERVERDIR}/webapps/solr.war -d ${SERVERDIR}/solr-webapp/webapp/ >> ${LOGDIR}/updateSolr.log 2>> ${LOGDIR}/updateSolr.error
    if [ $? -ne "0" ]; then
        helper_show_error "Error"
        return 1
    fi
    helper_show_success "Done"


    # Library: Extraction Libs
    helper_show_partial_message "Deploying Extraction Libs ... "
    cp -r ${TEMPFOLDER}/solr-${KLINK_SOLR_VERSION}/contrib/extraction ${BASEDIR}/solr/contrib/ &&
    cp -r ${TEMPFOLDER}/solr-${KLINK_SOLR_VERSION}/dist/solr-cell-*   ${BASEDIR}/solr/dist/
    if [ $? -ne "0" ]; then
        helper_show_error "Error"
        return 1
    fi
    helper_show_success "Done"    

    return 0
}

function solr_download_cleanup() {
    helper_show_partial_message "Removing temporary files ... "
    rm -fr ${TEMPFOLDER}/solr-${KLINK_SOLR_VERSION} &&
    rm -fr ${TEMPFOLDER}/langdetect-${KLINK_SOLR_LANGDETECT_VERSION}

    if [ $? -ne "0" ]; then
        helper_show_error "Error"
        helper_show_error " - Error while removing temp files!"
        return 1
    fi
    helper_show_success "Done"
    return 0
}

function checkSetup() {
    echo "KLink-SOLR: Setup Completed"
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

if ! langdetect_download; then
    helper_show_error " Check errors in ${LOGDIR}/updateSolr.error ${LOGDIR}/updateSolr.log"
    exit 1
fi

if ! langdetect_extract_files; then
    helper_show_error " Check errors in ${LOGDIR}/updateSolr.error ${LOGDIR}/updateSolr.log"
    exit 1
fi

if ! langdetect_deploy; then
    helper_show_error " Check errors in ${LOGDIR}/updateSolr.error ${LOGDIR}/updateSolr.log"
    exit 1
fi



# solr_download_cleanup

exit 0
