#!/bin/bash
DATE=`date +"%m-%d-%y %T"`
RECDIR=/var/lib/freeswitch/recordings/
DBHOST=`cat /var/lib/flux/flux-config.conf | grep dbhost | cut -c 10-`
DBUSER=`cat /var/lib/flux/flux-config.conf | grep dbuser | cut -c 10-`
DBPASS=`cat /var/lib/flux/flux-config.conf | grep dbpass | cut -c 10-`
DBNAME=`cat /var/lib/flux/flux-config.conf | grep dbname | cut -c 10-`
echo "[client]
user = $DBUSER
password = '$DBPASS'
host = $DBHOST
" > /tmp/.fluxdb.config
DAYS=$(echo 'select value from `system` where name="purge_recordings";' | mysql --defaults-extra-file=/tmp/.fluxdb.config $DBNAME | tail -n1)
if [ $DAYS -gt "0" ]; then
        NOFILES=$(/usr/bin/find $RECDIR -mindepth 0 -mtime +$DAYS | wc -l;)
        /usr/bin/find $RECDIR -mindepth 0 -mtime +$DAYS -exec rm -rf {} \;
fi
echo "[$DATE] ****** Total $NOFILES call recording files deleted ****** " >> /var/log/flux/purge_recordings.log
rm /tmp/.fluxdb.config