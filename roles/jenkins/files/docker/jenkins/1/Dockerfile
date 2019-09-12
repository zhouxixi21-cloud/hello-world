FROM devops/jenkins-base:2.32.1

MAINTAINER Terence Leung <terence.leung@rxpservices.com>

LABEL   app.version="jessie" \
        os.version="debian" \
        java.version="open jdk 8" \
        container.description="extended Jenkins image to allow configuration during image build"

ENV JENKINS_HOME="/var/jenkins_home" \
    JENKINS_SLAVE_AGENT_PORT=50000 \
    JENKINS_UID=1500 \
    JENKINS_USER="jenkins"

USER root

#install pip
RUN apt-get update -y && \
    apt-get install -y apt-utils && \
    apt-get install -y python-setuptools autoconf g++ python-dev && \
    easy_install pip

#install modules, ansible and pyaem
RUN pip install --upgrade setuptools pycrypto && \
    pip install --upgrade BeautifulSoup xmltodict && \
    apt-get install -y libffi-dev libssl-dev python-pycurl && \
    pip install --upgrade ansible==2.2.0.0 paramiko PyYAML Jinja2 httplib2 boto xmltodict six requests docker-py && \
    pip install https://github.com/wildone/pyaem/archive/master.zip && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#install tools
RUN apt-get update -y && apt-get install maven ruby groovy gradle ivy jython junit rsync -y

#switch to jdk 8
RUN update-java-alternatives -s java-1.8.0-openjdk-amd64

#because of https://issues.jenkins-ci.org/browse/JENKINS-31089 :
RUN sed -i "s/jdk.certpath.disabledAlgorithms=MD2, RSA keySize < 1024/jdk.certpath.disabledAlgorithms=MD2, RSA keySize < 512/g" \
   /etc/java-8-openjdk/security/java.security

#install proxytunnel and node
RUN apt-get update \
 && apt-get install -y proxytunnel nodejs npm \
 && rm -rf /var/lib/apt/lists/*

# Env
ENV PHANTOMJS_VERSION 2.1.1

# Phantomsjs
RUN \
  apt-get update && \
  apt-get upgrade -y && \
  apt-get install -y vim git wget libfreetype6 libfontconfig bzip2 && \
  mkdir -p /srv/var && \
  wget -q --no-check-certificate -O /tmp/phantomjs-$PHANTOMJS_VERSION-linux-x86_64.tar.bz2 https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-$PHANTOMJS_VERSION-linux-x86_64.tar.bz2 && \
  tar -xjf /tmp/phantomjs-$PHANTOMJS_VERSION-linux-x86_64.tar.bz2 -C /tmp && \
  rm -f /tmp/phantomjs-$PHANTOMJS_VERSION-linux-x86_64.tar.bz2 && \
  mv /tmp/phantomjs-$PHANTOMJS_VERSION-linux-x86_64/ /srv/var/phantomjs && \
  ln -s /srv/var/phantomjs/bin/phantomjs /usr/bin/phantomjs && \
  git clone https://github.com/n1k0/casperjs.git /srv/var/casperjs && \
  ln -s /srv/var/casperjs/bin/casperjs /usr/bin/casperjs && \
  apt-get autoremove -y && \
  apt-get clean all

# ImageMagick
RUN apt-get install --no-install-recommends -y -q chrpath libfreetype6 libfreetype6-dev libssl-dev libfontconfig1 imagemagick  && \
  apt-get autoremove -y && \
  apt-get clean all

# Install Open SSH to use this image as Jenkins Slave
RUN apt-get install -y openssh-server && \
    mkdir -p /var/run/sshd && \
    apt-get autoremove -y && \
    apt-get clean all

EXPOSE 22

# this should be used with DOCKER RUN when running as slave
# docker run -d -p 8122:22 devops/jenkins /usr/sbin/sshd -D


## 1. Install compile and runtime dependencies
## 2. Compile PhantomJS from the source code
## 3. Remove compile depdencies
## We do all in a single commit to reduce the image size (a lot!)
#RUN apt-get update \
#    && apt-get install -y build-essential ca-certificates g++ git flex bison gperf perl python ruby \
#    libsqlite3-dev libfontconfig1-dev libicu-dev libfreetype6 libssl-dev libpng-dev libjpeg-dev \
#    && mkdir /tmp/ \
#    && git clone --recurse-submodules https://github.com/ariya/phantomjs phantomjs \
#    && cd $_ \
#    && ./build.py --confirm --silent --jobs 2 \
#    && mv bin/phantomjs /usr/local/bin \
#    && cd \
#    && apt-get purge --auto-remove -y \
#        build-essential g++ git flex bison gperf ruby perl python \
#    && apt-get clean \
#    && rm -rf /tmp/* /var/lib/apt/lists/*

## Run as non-root user
#RUN useradd --system --uid 72379 -m --shell /usr/sbin/nologin phantomjs
#USER phantomjs


#udpate slave port
#ENV JENKINS_SLAVE_AGENT_PORT 50000

#add ssl
#COPY https.pem /var/lib/$JENKINS_USER/cert
#COPY https.key /var/lib/$JENKINS_USER/pk
#ENV JENKINS_OPTS --httpPort=-1 --httpsPort=8083 --httpsCertificate=/var/lib/$JENKINS_USER/cert --httpsPrivateKey=/var/lib/$JENKINS_USER/pk
#EXPOSE 8083

#run custom script
#COPY custom.groovy /usr/share/$JENKINS_USER/ref/init.groovy.d/custom.groovy

RUN echo "$JENKINS_USER ALL=NOPASSWD: ALL" >> /etc/sudoers

RUN mkdir -p /usr/share/$JENKINS_USER/ref/plugins

COPY plugins.txt /usr/share/$JENKINS_USER/plugins.txt

RUN chmod u=rwx /usr/local/bin/plugins.sh

RUN chown -R $JENKINS_USER /usr/share/$JENKINS_USER/ref /usr/share/$JENKINS_USER/ref/plugins /usr/local/bin/plugins.sh /usr/share/$JENKINS_USER/plugins.txt

USER $JENKINS_USER

#add more excutors
#COPY executors.groovy /usr/share/$JENKINS_USER/ref/init.groovy.d/executors.groovy
RUN /usr/local/bin/plugins.sh /usr/share/$JENKINS_USER/plugins.txt