FROM       devops/oracle-jdk:8u73-b02

MAINTAINER Terence Leung <terence.leung@rxpservices.com>

LABEL   os.version="centos" \
        container.description="docker nexus oss container without volume"

ENV NEXUS_DATA /nexus-data
ENV NEXUS_VERSION="3.0.2-02"
ENV MAX_HEAP="1200m"
ENV MIN_HEAP="1200m"
ENV CONTAINER_USER="nexus"
ENV CONTAINER_USERID="200"

#ENV JAVA_HOME /opt/java
#ENV JAVA_VERSION_MAJOR 8
#ENV JAVA_VERSION_MINOR 102
#ENV JAVA_VERSION_BUILD 14

RUN yum install -y \
  curl tar createrepo \
  && yum clean all

## install Oracle JRE
#RUN mkdir -p /opt \
#  && curl --fail --silent --location --retry 3 \
#  --header "Cookie: oraclelicense=accept-securebackup-cookie; " \
#  http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-b${JAVA_VERSION_BUILD}/server-jre-${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-linux-x64.tar.gz \
#  | gunzip \
#  | tar -x -C /opt \
#&& ln -s /opt/jdk1.${JAVA_VERSION_MAJOR}.0_${JAVA_VERSION_MINOR} ${JAVA_HOME}

RUN mkdir -p /opt/sonatype/nexus \
  && curl --fail --silent --location --retry 3 \
    https://download.sonatype.com/nexus/3/nexus-${NEXUS_VERSION}-unix.tar.gz \
  | gunzip \
  | tar x -C /opt/sonatype/nexus --strip-components=1 nexus-${NEXUS_VERSION} \
  && chown -R root:root /opt/sonatype/nexus

## configure nexus runtime env
RUN sed \
    -e "s|karaf.home=.|karaf.home=/opt/sonatype/nexus|g" \
    -e "s|karaf.base=.|karaf.base=/opt/sonatype/nexus|g" \
    -e "s|karaf.etc=etc|karaf.etc=/opt/sonatype/nexus/etc|g" \
    -e "s|java.util.logging.config.file=etc|java.util.logging.config.file=/opt/sonatype/nexus/etc|g" \
    -e "s|karaf.data=data|karaf.data=${NEXUS_DATA}|g" \
    -e "s|java.io.tmpdir=data/tmp|java.io.tmpdir=${NEXUS_DATA}/tmp|g" \
    -i /opt/sonatype/nexus/bin/nexus.vmoptions

RUN useradd -r -u ${CONTAINER_USERID} -m -c "nexus role account" -d ${NEXUS_DATA} -s /bin/false ${CONTAINER_USER}

#VOLUME ${NEXUS_DATA}

EXPOSE 8081 5000

WORKDIR /opt/sonatype/nexus

USER ${CONTAINER_USER}

ENV JAVA_MAX_MEM ${MAX_HEAP}
ENV JAVA_MIN_MEM ${MIN_HEAP}
ENV EXTRA_JAVA_OPTS ""

CMD ["bin/nexus", "run"]