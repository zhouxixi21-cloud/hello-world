FROM       devops/oracle-jdk:8u73-b02

MAINTAINER Terence Leung <terence.leung@rxpservices.com>

LABEL   os.version="centos" \
        container.description="mulesoft esb standalone"

ARG ESB_STANDALONE_VERSION
ARG ESB_STANDALONE_URL
ARG ESB_STANDALONE_SHA1SUM
ARG ESB_PACKAGE_VERSION
ARG ESB_PACKAGE_URL
ARG ESB_EXPOSE_PORTS="8080"

ENV JAVA_HOME /usr/java/jdk1.8.0_73
ENV TINI_VERSION v0.15.0

ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini

RUN chmod +x /tini \
 && yum -y install wget unzip less vim \
 && mkdir -p /tmp/mule-standalone \
 && cd /tmp/mule-standalone && wget -nv $ESB_STANDALONE_URL \
 && cd /opt && unzip /tmp/mule-standalone/mule-standalone-$ESB_STANDALONE_VERSION.zip \
 && echo "$ESB_STANDALONE_SHA1SUM /tmp/mule-standalone/mule-standalone-$ESB_STANDALONE_VERSION.zip" | sha1sum -c \
 && ln -s /opt/mule-standalone-$ESB_STANDALONE_VERSION /opt/mule

RUN if [ "$ESB_PACKAGE_VERSION" != "latest" ]; then wget -nv -O /tmp/mule-standalone/wkcd-esb-mule-$ESB_PACKAGE_VERSION.zip $ESB_PACKAGE_URL && mv /tmp/mule-standalone/wkcd-esb-mule-$ESB_PACKAGE_VERSION.zip /opt/mule/apps/wkcd-esb-mule-latest.zip; fi

RUN rm -rf /tmp/mule-standalone

EXPOSE $ESB_EXPOSE_PORTS

VOLUME ["/opt/mule/logs"]

CMD ["/opt/mule/bin/mule", "-D-Mmule.encoding=UTF-8"]

ENTRYPOINT ["/tini", "--"]
