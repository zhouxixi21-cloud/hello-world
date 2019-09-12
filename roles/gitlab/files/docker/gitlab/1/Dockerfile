FROM ubuntu:14.04

LABEL   os.version="ubuntu 14.04" \
        maintainer="terence.leung@rxpservices.com" \
        container.description="GitLab Community Edition docker image based on the Omnibus package"

ENV GITLAB_URL="https://packages.gitlab.com/gitlab/gitlab-ce/packages/ubuntu/trusty/" \
    GITLAB_FILE="gitlab-ce_8.7.3-ce.0_amd64.deb"

# Install required packages
RUN apt-get update -q && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
      ca-certificates \
      openssh-server \
      wget \
      apt-transport-https \
      vim \
      nano \
      patch \
      aria2

# Copy assets
COPY RELEASE /
COPY assets/ /assets/
#RUN /assets/setup

# Download & Install GitLab
#RUN curl -s https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | sudo bash && \
#    apt-get install gitlab-ce=8.6.2-ce.0

# If you run GitLab Enterprise Edition point it to a location where you have downloaded it.
#RUN curl -sSf "$APT_CONFIG_URL" > $APT_SOURCE_PATH
#RUN wget https://packages.gitlab.com/gitlab/gitlab-ce/ubuntu/pool/trusty/main/g/gitlab-ce/gitlab-ce_8.6.2-ce.0_amd64.deb && \
#    dpkg -i gitlab-ce_8.6.2-ce.0_amd64.deb && \
#    apt-get install -f

RUN aria2c -s 16 -x 16 --min-split-size=1M $GITLAB_URL$GITLAB_FILE/download && \
    dpkg -i $GITLAB_FILE && \
    apt-get install -f

#RUN echo "deb https://packages.gitlab.com/gitlab/gitlab-ce/ubuntu/ `lsb_release -cs` main" > /etc/apt/sources.list.d/gitlab_gitlab-ce.list && \
#    wget -q -O - https://packages.gitlab.com/gpg.key | apt-key add - && \
#    apt-get update && apt-get install -yq --no-install-recommends gitlab-ce

# Manage SSHD through runit
RUN mkdir -p /opt/gitlab/sv/sshd/supervise && \
    mkfifo /opt/gitlab/sv/sshd/supervise/ok && \
    printf "#!/bin/sh\nexec 2>&1\numask 077\nexec /usr/sbin/sshd -D" > /opt/gitlab/sv/sshd/run && \
    chmod a+x /opt/gitlab/sv/sshd/run && \
    ln -s /opt/gitlab/sv/sshd /opt/gitlab/service && \
    mkdir -p /var/run/sshd

# Disabling use DNS in ssh since it tends to slow connecting
RUN echo "UseDNS no" >> /etc/ssh/sshd_config

# Prepare default configuration
RUN ( \
  echo "" && \
  echo "# Docker options" && \
  echo "# Prevent Postgres from trying to allocate 25% of total memory" && \
  echo "postgresql['shared_buffers'] = '1MB'" ) >> /etc/gitlab/gitlab.rb && \
  mkdir -p /assets/ && \
  cp /etc/gitlab/gitlab.rb /assets/gitlab.rb

# Expose web & ssh
EXPOSE 443 80 22

# Define data volumes
#VOLUME ["/etc/gitlab", "/var/opt/gitlab", "/var/log/gitlab"]

# Copy assets
COPY assets/wrapper /usr/local/bin/

# Wrapper to handle signal, trigger runit and reconfigure GitLab
CMD ["/usr/local/bin/wrapper"]