FROM aem-dispatcher:4.1.12

MAINTAINER devops <devops@wkcda.hk>

LABEL   container.version="1.0" \
        os.version="centos 7" \
        httpd.version="2.4" \
        container.description="WKCDA DAM author dispatcher. "

ARG DISPATCHER_EXPOSE_PORTS="80 443"

ENV DISPATCHER_NAME=dispatcher
ENV RENDER_HOSTNAME=0.0.0.0
ENV RENDER_PORT=4502

EXPOSE $DISPATCHER_EXPOSE_PORTS

COPY httpd ./httpd/

USER root

RUN chown -R apache:apache /dispatcher

USER apache
