FROM        devops/oracle-jdk:8u73-b02

MAINTAINER  Yaw Ly

ARG SOLR_VERSION=6.3.0
ARG SOLR_INSTALL_DIR=/opt/solr
ARG SOLR_USER=solr
ARG SOLR_GROUP=solr
ARG SOLR_USEID=1011
ARG SOLR=solr-6.3.0
ARG SOLR_EXPOSE_PORTS="8983 9983"

COPY aemsolr /opt/$SOLR/server/aemsolr

RUN groupadd -g $SOLR_USEID $SOLR_GROUP \
 && useradd --uid $SOLR_USEID --gid $SOLR_USEID --groups $SOLR_GROUP  -m --shell /bin/bash $SOLR_USER  \
 && mkdir -p /opt /var/solr/data/oak_shard1_replica1 /var/solr/data/oak_shard1_replica2 \
 && yum -y install tar wget lsof curl procps \
 && wget -nv --output-document=/opt/$SOLR.tgz http://archive.apache.org/dist/lucene/solr/$SOLR_VERSION/$SOLR.tgz \
 && tar -C /opt --extract --file /opt/$SOLR.tgz \
 && rm /opt/$SOLR.tgz \
 && chown -R solr /opt/$SOLR /var/solr/data \
 && ln -s /opt/$SOLR $SOLR_INSTALL_DIR

EXPOSE $SOLR_EXPOSE_PORTS

USER $SOLR_USER

VOLUME ["/var/solr/data"]

CMD ["-f", "-cloud", "-m", "2g", "-s", "/opt/solr/server/aemsolr"]

ENTRYPOINT ["/opt/solr/bin/solr", "start"]
