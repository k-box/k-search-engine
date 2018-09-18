FROM openjdk:8-jre

ENV \
    LANGUAGE=en \
    LC_ALL=$LANG \
    SOLR_VERSION="7.4.0" \
    SOLR_DEPLOY_DIR="/opt/solr" \
    SOLR_UID=500 \
    SOLR_GID=500 \
    SOLR_DOWNLOAD_DIR="${SOLR_DEPLOY_DIR}/downloads" \
    INDEX_NAME="k-search"

# Create a non-root user solr can run under
RUN groupadd -r -g ${SOLR_GID} solr && useradd -r -u ${SOLR_UID} -g solr solr

WORKDIR /opt/solr

# Install dependencies
RUN \
    apt-get update &&\
    apt-get --no-install-recommends --yes install gosu &&\
    apt-get clean &&\
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

## Download and extract SOLR, then install it 
RUN echo "Downloading SOLR ${SOLR_VERSION}..." \ 
    && mkdir $SOLR_DOWNLOAD_DIR \
    && curl --progress-bar --retry 10 --output "${SOLR_DOWNLOAD_DIR}/solr-${SOLR_VERSION}.zip" "https://archive.apache.org/dist/lucene/solr/${SOLR_VERSION}/solr-${SOLR_VERSION}.zip" \
    && curl --progress-bar --retry 10 --output "${SOLR_DOWNLOAD_DIR}/solr-${SOLR_VERSION}.zip.sha1" "https://archive.apache.org/dist/lucene/solr/${SOLR_VERSION}/solr-${SOLR_VERSION}.zip.sha1" \
    && echo "Verifying file checksum..." \ 
    && cd $SOLR_DOWNLOAD_DIR && sha1sum -c "solr-${SOLR_VERSION}.zip.sha1" \
    && cd $SOLR_DEPLOY_DIR \
    && echo "Extracting SOLR ${SOLR_VERSION}..." \ 
    && unzip -qq -o -d "${SOLR_DOWNLOAD_DIR}/solr-${SOLR_VERSION}" "${SOLR_DOWNLOAD_DIR}/solr-${SOLR_VERSION}.zip" \
    && echo "Deploy SOLR folders Context... " \
    && cd "${SOLR_DOWNLOAD_DIR}/solr-${SOLR_VERSION}/solr-${SOLR_VERSION}" \
    && cp --force --recursive --target-directory="${SOLR_DEPLOY_DIR}" bin contrib dist server && cd $SOLR_DEPLOY_DIR \
    && echo "Cleaning up temporary files... " \
    && rm -r "${SOLR_DOWNLOAD_DIR}" \
    && echo "Adding SOLR extraction library..." \
    && curl --progress-bar --retry 10 --output "${SOLR_DEPLOY_DIR}/contrib/extraction/lib/jhighlight-1.0.jar" "https://repo1.maven.org/maven2/com/uwyn/jhighlight/1.0/jhighlight-1.0.jar" \
    && echo "Done!"

## Copying over the configuration
COPY . /opt/solr

## Apply the configuration and make sure the start.sh script is executable
RUN cp -r ./solr-conf/conf ${SOLR_DEPLOY_DIR}/${INDEX_NAME}/${INDEX_NAME}/ \
    && cp -r ./solr-conf/core.properties ${SOLR_DEPLOY_DIR}/${INDEX_NAME}/${INDEX_NAME}/ \
    && cp -r ./solr-conf/solr.xml ${SOLR_DEPLOY_DIR}/${INDEX_NAME}/ \
    && cp --force --recursive ${SOLR_DEPLOY_DIR}/server-override/* ${SOLR_DEPLOY_DIR}/server/ \ 
    && chmod a+x ${SOLR_DEPLOY_DIR}/start.sh

## This is the volume where the search engine index is stored
VOLUME ["/opt/solr/k-search/k-search/data"]

EXPOSE 8983

ENTRYPOINT ["/opt/solr/start.sh"]
CMD ["start"]
