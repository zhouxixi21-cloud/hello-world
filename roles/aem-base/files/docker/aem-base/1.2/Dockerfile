FROM devops/oracle-jdk:8u73-b02

MAINTAINER Terence Leung <terence.leung@rxpservices.com>

LABEL   container.version="1.0" \
        os.version="centos 7" \
        java.version="oracle 8" \
        container.description="base image for AEM instances"

# setup ffmpeg
# source: https://github.com/jrottenberg/ffmpeg
ENV           FFMPEG_VERSION=3.0.1 \
              YASM_VERSION=1.3.0   \
              NASM_VERSION=2.13.01  \
              OGG_VERSION=1.3.2    \
              VORBIS_VERSION=1.3.5 \
              THEORA_VERSION=1.1.1 \
              LAME_VERSION=3.99.5  \
              OPUS_VERSION=1.1.1   \
              FAAC_VERSION=1.28    \
              VPX_VERSION=1.5.0    \
              XVID_VERSION=1.3.4   \
              FDKAAC_VERSION=0.1.4 \
              X265_VERSION=1.9

WORKDIR       /tmp/workdir

COPY          ffmpeg.sh /tmp/ffmpeg.sh

RUN           chmod 700 /tmp/ffmpeg.sh && /tmp/ffmpeg.sh && ffmpeg -buildconf

# setup jre fallback fonts
RUN yum makecache fast && yum install -y \
    unzip wget cjkuni-ukai-fonts.noarch cjkuni-uming-fonts.noarch && \
    mkdir -p /usr/java/default/jre/lib/fonts/fallback && \
    cp /usr/share/fonts/cjkuni-ukai/ukai.ttc /usr/java/default/jre/lib/fonts/fallback && \
    cp /usr/share/fonts/cjkuni-uming/uming.ttc /usr/java/default/jre/lib/fonts/fallback && \
    wget -nv -O /tmp/msft-fonts.zip "https://docs.google.com/uc?id=0B3Uxax626E5DOVdJNjc0TW9Mbmc&export=download" && \
    cd /tmp && unzip msft-fonts.zip && \
    cp /tmp/msft-fonts/* /usr/java/default/jre/lib/fonts/fallback && \
    rm -fr /tmp/msft-fonts /tmp/msft-fonts.zip

# 32-bit runtime libs for xmp write-back
# https://helpx.adobe.com/experience-manager/kb/enable-xmp-write-back-64-bit-redhat.html
RUN yum upgrade -y && \
    yum install -y \
    ld-linux.so.2 glibc.i686 libuuid.i686

# setup exiftool
RUN wget -nv -O /tmp/epel-release-7-11.noarch.rpm http://dl.fedoraproject.org/pub/epel/7/x86_64/Packages/e/epel-release-7-11.noarch.rpm && \
    cd /tmp && rpm -Uvh epel-release-7-11.noarch.rpm && \
    yum install -y perl-Image-ExifTool && \
    rm -fr /tmp/epel-release-7-11.noarch.rpm

CMD ["/bin/bash"]
