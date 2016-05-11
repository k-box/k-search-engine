FROM openjdk:7-jre

# consider this alternative image:
# https://registry.hub.docker.com/u/makuk66/docker-solr/
ENV LANGUAGE en
ENV LC_ALL $LANG

COPY . /opt/solr
ENV KLINK_SETUP_DOWNLOADFOLDER /opt/solr/downloads

RUN curl --retry 10 --output $KLINK_SETUP_DOWNLOADFOLDER/solr-4.10.4.zip http://archive.apache.org/dist/lucene/solr/4.10.4/solr-4.10.4.zip \
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
