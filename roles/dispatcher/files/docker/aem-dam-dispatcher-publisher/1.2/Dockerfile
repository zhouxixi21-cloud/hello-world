FROM aem-dispatcher:1

MAINTAINER devops <devops@wkcda.hk>

LABEL   container.version="1.0" \
        os.version="centos 7" \
        httpd.version="2.4" \
        container.description="WKCDA DAM publish dispatcher. "

ENV DISPATCHER_NAME=dispatcher
ENV RENDER_HOSTNAME=0.0.0.0
ENV RENDER_PORT=4503

COPY httpd ./httpd/

USER root

RUN chown -R apache:apache /dispatcher

USER apache
