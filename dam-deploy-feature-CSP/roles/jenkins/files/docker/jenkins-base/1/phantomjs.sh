#!/usr/bin/env bash
set -ex

# 1. Install compile and runtime dependencies
# 2. Compile PhantomJS from the source code
# 3. Remove compile depdencies
# We do all in a single commit to reduce the image size (a lot!)

#apt-get update \
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

export DEBIAN_FRONTEND=noninteractive

apt-get update

apt-get -qqy dist-upgrade

apt-get install -qqy build-essential g++ flex bison gperf ruby perl \
  libsqlite3-dev libfontconfig1-dev libicu-dev libfreetype6 libssl-dev \
  libpng-dev libjpeg-dev python libx11-dev libxext-dev git

git clone https://github.com/ariya/phantomjs.git /phantomjs
cd /phantomjs
git checkout 2.0
./build.sh --confirm
mv bin/phantomjs /usr/local/bin
cd /
rm -rf /phantomjs

apt-get autoremove -qqy && \
apt-get clean && apt-get autoclean && \
rm -rf /usr/share/man/?? && rm -rf /usr/share/man/??_*