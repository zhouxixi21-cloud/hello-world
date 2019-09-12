#!/bin/bash 

mkdir -p /aem/crx-quickstart/logs

LOG=/aem/crx-quickstart/logs/start_history.log

function log() {
   echo "`date` $1">>"$LOG"
}

log "Checking If First Time"

# check if has been extracted earlier
if [ ! -d "/aem/crx-quickstart/bin" ] ; then

    log "===================================================="
    log "Unpacking AEM Package"
    cd /aem; java -jar cq-quickstart-6.jar -unpack >>"$LOG"
    log "Unpacking Is DONE"
    log "----------------------------------------------------"
    log "Copying Configuration files"
    mkdir -p /aem/crx-quickstart/install && cp -a /aem/install/. /aem/crx-quickstart/install/
    log "===================================================="
    log "Install DONE"

fi

# Merged from /crx-quickstart/bin/start and /crx-quickstart/bin/quickstart
#
# This script configures the start information for this server.
#
# The following variables may be used to override the defaults.
# For one-time overrides the variable can be set as part of the command-line; e.g.,
#
#     % CQ_PORT=1234 ./start
#

#Force all ports
#CQ_PORT=8080
CQ_DEBUG_PORT=58242

# TCP port used for stop and status scripts
if [ -z "$CQ_PORT" ]; then
   CQ_PORT=4502
fi

# hostname of the interface that this server should listen to
#if [ -z "$CQ_HOST" ]; then
#   =
#fi

# runmode(s)
# will not be used if repository is already present
if [ -z "$CQ_RUNMODE" ]; then
   CQ_RUNMODE='author'
fi

# name of the jarfile
#if [ -z "$CQ_JARFILE" ]; then
#   CQ_JARFILE=''
#fi

# default JVM options
if [ -z "$CQ_JVM_OPTS" ]; then
   CQ_JVM_OPTS='-server -Xmx1024m -XX:MaxPermSize=256M -Djava.awt.headless=true'
fi

# file size limit (ulimit)
if [ -z "$CQ_FILE_SIZE_LIMIT" ]; then
   CQ_FILE_SIZE_LIMIT=8192
fi

# ------------------------------------------------------------------------------
# authentication
# ------------------------------------------------------------------------------
# when using oak (crx3) authentication must be configured using the
# Apache Felix JAAS Configuration Factory service via the Web Console
# see http://jackrabbit.apache.org/oak/docs/security/authentication/externalloginmodule.html

# use jaas.config (legacy: only used for crx2 persistence)
#if [ -z "$CQ_USE_JAAS" ]; then
#   CQ_USE_JAAS='true'
#fi

# config for jaas (legacy: only used for crx2 persistence)
#if [ -z "$CQ_JAAS_CONFIG" ]; then
#   CQ_JAAS_CONFIG='etc/jaas.config'
#fi

# ------------------------------------------------------------------------------
# persistence mode
# ------------------------------------------------------------------------------
# the persistence mode can not be switched for an existing repository
CQ_RUNMODE="${CQ_RUNMODE},crx3,crx3tar"
#CQ_RUNMODE="${CQ_RUNMODE},crx3,crx3mongo"

# settings for mongo db
#if [ -z "$CQ_MONGO_HOST" ]; then
#   CQ_MONGO_HOST=127.0.0.1
#fi
#if [ -z "$CQ_MONGO_PORT" ]; then
#   CQ_MONGO_PORT=27017
#fi
#if [ -z "$CQ_MONGO_DB" ]; then
#   CQ_MONGO_DB=aem6
#fi

# ------------------------------------------------------------------------------
# do not configure below this point
# ------------------------------------------------------------------------------

if [ $CQ_FILE_SIZE_LIMIT ]; then
   CURRENT_ULIMIT=`ulimit`
   if [ $CURRENT_ULIMIT != "unlimited" ]; then
      if [ $CURRENT_ULIMIT -lt $CQ_FILE_SIZE_LIMIT ]; then
         echo "ulimit ${CURRENT_ULIMIT} is too small (must be at least ${CQ_FILE_SIZE_LIMIT})"
         exit 1
      fi
   fi
fi

CQ_JARFILE=`find /aem/crx-quickstart/app/ -name "*quickstart.jar" -print -quit`
CURR_DIR="/aem/crx-quickstart"

#BIN_PATH=$(dirname $0)
#cd $BIN_PATH/..
#if [ -z $CQ_JARFILE ]; then
#   CQ_JARFILE=`ls app/*.jar | head -1`
#fi
#CURR_DIR=$(basename $(pwd))
#cd ..

START_OPTS="start -c ${CURR_DIR} -i launchpad"
if [ $CQ_PORT ]; then
   START_OPTS="${START_OPTS} -p ${CQ_PORT}"
fi

#merged from quickstart
#if [ $CQ_GUI ]; then
#   START_OPTS="${START_OPTS} -gui"
#fi
if [ $CQ_VERBOSE ]; then
   START_OPTS="${START_OPTS} -verbose"
fi
if [ $CQ_NOFORK ]; then
   START_OPTS="${START_OPTS} -nofork"
fi
if [ $CQ_FORK ]; then
   START_OPTS="${START_OPTS} -fork"
fi
if [ $CQ_FORKARGS ]; then
   START_OPTS="${START_OPTS} -forkargs ${CQ_FORKARGS}"
fi
if [ $CQ_LOWMEMACTION ]; then
   START_OPTS="${START_OPTS} -low-mem-action ${CQ_LOWMEMACTION}"
fi

if [ $CQ_RUNMODE ]; then
   CQ_JVM_OPTS="${CQ_JVM_OPTS} -Dsling.run.modes=${CQ_RUNMODE}"
fi
if [ $CQ_HOST ]; then
   CQ_JVM_OPTS="${CQ_JVM_OPTS} -Dorg.apache.felix.http.host=${CQ_HOST}"
    START_OPTS="${START_OPTS} -a ${CQ_HOST}"
fi
if [ $CQ_MONGO_HOST ]; then
    START_OPTS="${START_OPTS} -Doak.mongo.host=${CQ_MONGO_HOST}"
fi
if [ $CQ_MONGO_PORT ]; then
    START_OPTS="${START_OPTS} -Doak.mongo.port=${CQ_MONGO_PORT}"
fi
if [ $CQ_MONGO_DB ]; then
    START_OPTS="${START_OPTS} -Doak.mongo.db=${CQ_MONGO_DB}"
fi

if [ $CQ_USE_JAAS ]; then
    CQ_JVM_OPTS="${CQ_JVM_OPTS} -Djava.security.auth.login.config=${CQ_JAAS_CONFIG}"
fi
START_OPTS="${START_OPTS} -Dsling.properties=conf/sling.properties"

if [ $CQ_DEBUG ]; then
    CQ_JVM_OPTS="${CQ_JVM_OPTS} -Xdebug -Xrunjdwp:transport=dt_socket,server=y,address=${CQ_DEBUG_PORT},suspend=n"
fi

if [ $CQ_MONITOR ]; then
    if [ -z "$CQ_MONITOR_PORT" ]; then
       CQ_MONITOR_PORT=3333
    fi
    #allow visual VM to connect
    CQ_JVM_OPTS="${CQ_JVM_OPTS} -Dcom.sun.management.jmxremote.port=${CQ_MONITOR_PORT} -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false"
fi

# timezone
if [ "$CQ_TZ" ]; then
    CQ_JVM_OPTS="${CQ_JVM_OPTS} -Duser.timezone=${CQ_TZ}"
fi

CQ_JVM_OPTS="${CQ_JVM_OPTS} -Dsun.jnu.encoding=UTF-8 -Dfile.encoding=UTF-8"

#allow override of everything!!!
CQ_JVM_OPTS=${CQ_JVM_OPTS_OVD:-$CQ_JVM_OPTS}
CQ_START_OPT=${CQ_START_OPTS_OVD:-$START_OPTS}

log "java $CQ_JVM_OPTS -jar $CQ_JARFILE $CQ_START_OPT"

log "Starting..."

##IF UPGRADE
#if [ $CQ_UPGRADE ]; then
#    CQ_START_OPT="-r"
#fi

trap '/aem/crx-quickstart/bin/stop' TERM INT
java $CQ_JVM_OPTS -jar $CQ_JARFILE $CQ_START_OPT &
PID=$!
wait $PID
trap - TERM INT
wait $PID
EXIT_STATUS=$?