FROM centos:centos7

MAINTAINER devops <devops@wkcda.hk>

LABEL   container.version="1.0" \
        os.version="centos 7" \
        httpd.version="2.4" \
        container.description="base apache image"

ARG APACHE_RUN_USER="apache"
ARG APACHE_RUN_GROUP="apache"
ARG APACHE_RUN_USEID=1100

RUN groupadd -g$APACHE_RUN_USEID $APACHE_RUN_GROUP && \
    useradd --uid $APACHE_RUN_USEID --gid $APACHE_RUN_USEID --groups $APACHE_RUN_GROUP -m --shell /bin/bash $APACHE_RUN_USER && \
    yum -y install httpd mod_ssl && \
    yum clean all;

CMD ["/bin/bash"]
