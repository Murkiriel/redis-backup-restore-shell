#!/bin/sh

if [ ! -d "/backup/redis/" ]; then
  mkdir /backup/
  mkdir /backup/redis/
fi

DIR=`cat /etc/redis/redis.conf |grep '^dir '|cut -d' ' -f2`

redis-cli bgsave

cp $DIR/dump.rdb /backup/redis/dump.$(date +%Y%m%d%H%M).rdb
