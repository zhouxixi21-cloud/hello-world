FROM       centos:centos7

ARG JDK_DOWNLOAD_URL

MAINTAINER Yaw Ly <yaw.ly@rxpservices.com>

LABEL   os.version="centos" \
        container.description="oracle jdk 8"

WORKDIR /tmp

ADD $JDK_DOWNLOAD_URL .

RUN yum -y install sed && \
    AUTO_JDKFILE=$(echo $JDK_DOWNLOAD_URL | sed 's,^[^ ]*/,,' ) && \
    rpm -Uvh ${AUTO_JDKFILE} && \
    rm -f ${AUTO_JDKFILE}
