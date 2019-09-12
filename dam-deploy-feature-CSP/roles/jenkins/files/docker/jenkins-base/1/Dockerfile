FROM java:8-jdk

MAINTAINER Terence Leung <terence.leung@rxpservices.com>

LABEL   app.version="jessie" \
        os.version="debian" \
        java.version="open jdk 8" \
        docker.source="https://hub.docker.com/_/jenkins/" \
        docker.dockerfile="https://github.com/jenkinsci/docker/blob/master/Dockerfile" \
        docker.version="2.121.2" \
        container.description="extended Jenkins Base"

RUN apt-get update && apt-get install -y wget git curl zip && rm -rf /var/lib/apt/lists/*

ENV JENKINS_HOME="/var/jenkins_home" \
    JENKINS_SLAVE_AGENT_PORT=50000 \
    JENKINS_UID=1500 \
    JENKINS_USER="jenkins"

# Jenkins is run with user `jenkins`, uid = 1000
# If you bind mount a volume from the host or a data container,
# ensure you use the same uid
RUN useradd -d "$JENKINS_HOME" -u $JENKINS_UID -m -s /bin/bash $JENKINS_USER

# Jenkins home directory is a volume, so configuration and build history
# can be persisted and survive image upgrades
#VOLUME /var/jenkins_home

# `/usr/share/$JENKINS_USER/ref/` contains all reference configuration we want
# to set on a fresh new installation. Use it to bundle additional plugins
# or config file with your custom jenkins Docker image.
RUN mkdir -p /usr/share/$JENKINS_USER/ref/init.groovy.d

ENV TINI_SHA 066ad710107dc7ee05d3aa6e4974f01dc98f3888

# Use tini as subreaper in Docker container to adopt zombie processes
RUN curl -fL https://github.com/krallin/tini/releases/download/v0.5.0/tini-static -o /bin/tini && chmod +x /bin/tini \
  && echo "$TINI_SHA /bin/tini" | sha1sum -c -

COPY init.groovy /usr/share/$JENKINS_USER/ref/init.groovy.d/tcp-slave-agent-port.groovy

# SHA checksum according to http://repo.jenkins-ci.org/releases/org/jenkins-ci/main/jenkins-war/2.121.2/jenkins-war-2.121.2.war.sha1
ENV JENKINS_VERSION 2.121.2
ENV JENKINS_SHA b46ff03ae2898694d0cbb9ede823fef6090216ca


# could use ADD but this one does not check Last-Modified header
# see https://github.com/docker/docker/issues/8331
RUN curl -fL http://mirrors.jenkins-ci.org/war-stable/$JENKINS_VERSION/jenkins.war -o /usr/share/$JENKINS_USER/jenkins.war \
  && echo "$JENKINS_SHA /usr/share/$JENKINS_USER/jenkins.war" | sha1sum -c -

ENV JENKINS_UC https://updates.jenkins-ci.org
RUN chown -R $JENKINS_USER "$JENKINS_HOME" /usr/share/$JENKINS_USER/ref

# for main web interface:
EXPOSE 8080

# will be used by attached slave agents:
EXPOSE 50000

ENV COPY_REFERENCE_FILE_LOG $JENKINS_HOME/copy_reference_file.log

USER $JENKINS_USER

COPY jenkins.sh /usr/local/bin/jenkins.sh
ENTRYPOINT ["/bin/tini", "--", "/usr/local/bin/jenkins.sh"]

# from a derived Dockerfile, can use `RUN plugins.sh active.txt` to setup /usr/share/$JENKINS_USER/ref/plugins from a support bundle
COPY plugins.sh /usr/local/bin/plugins.sh