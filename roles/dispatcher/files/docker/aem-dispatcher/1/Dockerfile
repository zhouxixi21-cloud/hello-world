FROM aem-apache:1

MAINTAINER devops <devops@wkcda.hk>

LABEL   container.version="1.0" \
        os.version="centos 7" \
        httpd.version="2.4" \
        container.description="base image got AEM instances"

ARG APACHE_VERSION
ARG DISPATCHER_VERSION

ENV APACHE_MODULES="/dispatcher/httpd/modules"

WORKDIR /dispatcher

COPY start.sh ./
COPY httpd/ ./httpd

RUN mkdir -p /data && \
    mkdir -p /dispatcher/httpd/modules $APACHE_MODULES/ssl09 $APACHE_MODULES/ssl10 && \
    tar --directory $APACHE_MODULES --extract --overwrite --overwrite -f $APACHE_MODULES/src/dispatcher-$APACHE_VERSION-linux-x86-64-$DISPATCHER_VERSION.tar.gz dispatcher-$APACHE_VERSION-$DISPATCHER_VERSION.so && \
    tar --directory $APACHE_MODULES/ssl09 --extract --overwrite --overwrite -f $APACHE_MODULES/src/dispatcher-$APACHE_VERSION-linux-x86-64-ssl09-$DISPATCHER_VERSION.tar.gz dispatcher-$APACHE_VERSION-$DISPATCHER_VERSION.so && \
    tar --directory $APACHE_MODULES/ssl10 --extract --overwrite --overwrite -f $APACHE_MODULES/src/dispatcher-$APACHE_VERSION-linux-x86-64-ssl10-$DISPATCHER_VERSION.tar.gz dispatcher-$APACHE_VERSION-$DISPATCHER_VERSION.so && \
    chown -R apache:apache /dispatcher && \
    chown -R apache:apache /data && \
    chown -R apache:apache /run/httpd && \
    chmod +x /dispatcher/start.sh

USER apache

VOLUME /data

EXPOSE 8080 8443

ENTRYPOINT ["/dispatcher/start.sh"]
