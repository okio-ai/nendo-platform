#!/bin/bash

BACKUP_FILE_NAME=$(date +"%Y%m%d%H%M%S")-redis-backup.rdb
DOCKER_VOLUME="nendo-platform_redis-data"
BACKUP_DIR=$1
VOLUME_PATH=$(docker volume inspect --format '{{ .Mountpoint }}' $DOCKER_VOLUME)

echo $VOLUME_PATH
cp $VOLUME_PATH/dump.rdb $BACKUP_DIR/$BACKUP_FILE_NAME
