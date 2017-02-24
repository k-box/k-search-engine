FROM openjdk:8-jre

# consider this alternative image:
# https://registry.hub.docker.com/u/makuk66/docker-solr/
ENV LANGUAGE en
ENV LC_ALL $LANG
ENV KLINK_SOLR_VERSION 5.5.4

COPY . /opt/solr
ENV KLINK_SETUP_DOWNLOADFOLDER /opt/solr/downloads

# Coping over the conf directory and properties
RUN cp -r /opt/solr/solr-conf/conf            /opt/solr/solr-cloud/klink-public/ \
 && cp -r /opt/solr/solr-conf/core.properties /opt/solr/solr-cloud/klink-public/ \
 && cp -r /opt/solr/solr-conf/solr.xml        /opt/solr/solr-cloud/

RUN cp -r /opt/solr/solr-conf/conf            /opt/solr/solr-private/klink-private/ \
 && cp -r /opt/solr/solr-conf/core.properties /opt/solr/solr-private/klink-private/ \
 && cp -r /opt/solr/solr-conf/solr.xml        /opt/solr/solr-private/


RUN curl --retry 10 --output $KLINK_SETUP_DOWNLOADFOLDER/solr-${KLINK_SOLR_VERSION}.zip http://archive.apache.org/dist/lucene/solr/${KLINK_SOLR_VERSION}/solr-${KLINK_SOLR_VERSION}.zip \
	&& cd /opt/solr && ./updateSolr.sh \
    && rm -rf ${KLINK_SETUP_DOWNLOADFOLDER}/*

RUN tar cJf /opt/solr/solr-cloud/klink-public/data.tar.xz -C /opt/solr/solr-cloud/klink-public/data . \
    && tar cJf /opt/solr/solr-private/klink-private/data.tar.xz -C /opt/solr/solr-private/klink-private/data .

# sleep is to avoid "file in use" errors, a bug from docker it seems
#RUN sleep 1 && chmod a+x /opt/solr/klinkSolr-globalsearch.sh /opt/solr/klinkSolr-localsearch.sh
RUN chmod a+x /opt/solr/klinkSolr-globalsearch.sh /opt/solr/klinkSolr-localsearch.sh

WORKDIR /opt/solr

# expose both global and local directories and ports. they will be selected from the launch config
VOLUME ["/opt/solr/solr-cloud/klink-public/data", "/opt/solr/solr-private/klink-private/data"]

EXPOSE 8983 8984

CMD ["/opt/solr/klinkSolr-globalsearch.sh", "start-foreground"]
