#!/bin/sh

DIR=`cat /etc/redis/redis.conf |grep '^dir '|cut -d' ' -f2`

AOF=`cat /etc/redis/redis.conf |grep 'appendonly '|cut -d' ' -f2`

/etc/init.d/redis-server stop

RDB=`ls /backup/redis/ -t |head -1`

if [ "$AOF" = "no" ]; then
  rm -f $DIR/dump.rdb

  cp /backup/redis/$RDB $DIR/dump.rdb

  chown redis:redis $DIR/dump.rdb

  /etc/init.d/redis-server start
else
  rm -f $DIR/dump.rdb $DIR/appendonly.aof

  cp /backup/redis/$RDB $DIR/dump.rdb

  chown redis:redis $DIR/dump.rdb

  sed -i "s/appendonly yes/appendonly no/g" /etc/redis/redis.conf

  /etc/init.d/redis-server start

  redis-cli BGREWRITEAOF

  RIP="aof_rewrite_in_progress:1"

  while [ RIP = "aof_rewrite_in_progress:1" ]; do
    RIP=`redis-cli info | grep aof_rewrite_in_progress`
  done

  /etc/init.d/redis-server stop

  sed -i "s/appendonly no/appendonly yes/g" /etc/redis/redis.conf

  /etc/init.d/redis-server start
fi
