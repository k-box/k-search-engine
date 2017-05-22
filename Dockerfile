FROM openjdk:8-jre

ENV LANGUAGE en
ENV LC_ALL $LANG

## The SOLR version to be used
ENV SOLR_VERSION "5.5.4"

## Where we will install everything
ENV SOLR_DEPLOY_DIR "/opt/solr"
ENV SOLR_DOWNLOAD_DIR "${SOLR_DEPLOY_DIR}/downloads"

## SOLR index name
ENV INDEX_NAME "k-search"

WORKDIR /opt/solr

## Download and extract SOLR, then install it 
RUN echo "Downloading SOLR ${SOLR_VERSION}..." \ 
    && mkdir $SOLR_DOWNLOAD_DIR \
    && curl --progress-bar --retry 10 --output "${SOLR_DOWNLOAD_DIR}/solr-${SOLR_VERSION}.zip" "http://archive.apache.org/dist/lucene/solr/${SOLR_VERSION}/solr-${SOLR_VERSION}.zip" \
    && curl --progress-bar --retry 10 --output "${SOLR_DOWNLOAD_DIR}/solr-${SOLR_VERSION}.zip.sha1" "http://archive.apache.org/dist/lucene/solr/${SOLR_VERSION}/solr-${SOLR_VERSION}.zip.sha1" \
    && echo "Verifying file checksum..." \ 
    && cd $SOLR_DOWNLOAD_DIR && sha1sum -c "solr-${SOLR_VERSION}.zip.sha1" && cd $SOLR_DEPLOY_DIR \
    && echo "Extracting SOLR ${SOLR_VERSION}..." \ 
    && unzip -qq -o -d "${SOLR_DOWNLOAD_DIR}/solr-${SOLR_VERSION}" "${SOLR_DOWNLOAD_DIR}/solr-${SOLR_VERSION}.zip" \
    && echo "Deploy SOLR folders Context... " \
    && cd "${SOLR_DOWNLOAD_DIR}/solr-${SOLR_VERSION}/solr-${SOLR_VERSION}" && cp --force --recursive --target-directory="${SOLR_DEPLOY_DIR}" bin contrib dist server && cd $SOLR_DEPLOY_DIR \
    && echo "Cleaning up temporary files... " \
    && rm -r "${SOLR_DOWNLOAD_DIR}"

## Copying over the configuration
COPY . /opt/solr

## Apply the configuration and make sure the start.sh script is exectable
RUN cp -r ./solr-conf/conf ${SOLR_DEPLOY_DIR}/${INDEX_NAME}/${INDEX_NAME}/ \
    && cp -r ./solr-conf/core.properties ${SOLR_DEPLOY_DIR}/${INDEX_NAME}/${INDEX_NAME}/ \
    && cp -r ./solr-conf/solr.xml ${SOLR_DEPLOY_DIR}/${INDEX_NAME}/ \
    && cp --force --recursive ${SOLR_DEPLOY_DIR}/server-override/* ${SOLR_DEPLOY_DIR}/server/ \ 
    && chmod a+x ${SOLR_DEPLOY_DIR}/start.sh

## This is the volume where the search engine index is stored
VOLUME ["/opt/solr/k-search/k-search/data"]

EXPOSE 8983

ENTRYPOINT ["/opt/solr/start.sh"]
