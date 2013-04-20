#!/bin/sh
#
# Usage:
#
# backup.sh SRC_DIR DEST_BASE_DIR GENERATIONS
#
# When SRC_DIR is hoge:/var/www and
# DEST_BASE_DIR is /var/backups, these directories are created.
#
# /var/backups/20130420_132312/www
#             /20130421_132214/www
#             /20130422_132010/www

set -ex

SRC_DIR=$1
DEST_BASE_DIR=$2
GENERATIONS=$3

if [ $# != 3 ]; then
	echo "Usage: backup.sh SRC_DIR DEST_BASE_DIR GENERATIONS" >&2
	exit 1
fi

dir_count() {
	DIR=$1
	echo $(ls $DIR | wc -l)
}

latest_dir() {
	DIR=$1
	echo $(ls -t $DIR | head -n 1)
}

oldest_dir() {
	DIR=$1
	echo $(ls -t $DIR | tail -n 1)
}

mkdir -p $DEST_BASE_DIR
echo $(dir_count $DEST_BASE_DIR)
echo $(latest_dir $DEST_BASE_DIR)
echo $(oldest_dir $DEST_BASE_DIR)

LATEST_NAME=$(date +"%Y%m%d_%H%M%S")
SECOND_LATEST_NAME=$(latest_dir $DEST_BASE_DIR)

mkdir -p $DEST_BASE_DIR/$LATEST_NAME

OPTIONS="-avvz"
if [ -n "$SECOND_LATEST_NAME" ]; then
	OPTIONS="${OPTIONS} --link-dest=$DEST_BASE_DIR/$SECOND_LATEST_NAME/"
fi

rsync $OPTIONS $SRC_DIR $DEST_BASE_DIR/$LATEST_NAME/

if [ $(dir_count $DEST_BASE_DIR) -gt $GENERATIONS ]; then
	rm -rf $DEST_BASE_DIR/$(oldest_dir $DEST_BASE_DIR)
fi
