#!/bin/bash
set -e

# Paths required by httpd on startup
if [ ! -d "/data/httpd" ]; then
    mkdir -p /data/httpd /data/httpd/cache /data/httpd/logs /data/httpd/run /data/httpd/cgi-bin

    # make sure permissions set to current user

    chown -R $APACHE_RUN_USER:$APACHE_RUN_GROUP /data/httpd
fi

# Apache gets grumpy about PID files pre-existing
rm -f /data/httpd/run/httpd.pid

exec httpd -f /dispatcher/httpd/httpd.conf -DFOREGROUND