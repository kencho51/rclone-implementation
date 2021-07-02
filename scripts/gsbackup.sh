#!/usr/bin/bash

backup_date=`date "+%Y%m%d"`
test_dir="/Volumes/kencho/rclone-implementation"
source_dir="/Volumes/kencho/rclone-implementation/scripts/"
destination_dir="google-drive:rclone_backup"

#echo $backup_date
#echo $test_dir/logs/$backup_date.log

# To sync destination dir with source dir
/usr/local/bin/rclone --checksum -vv sync $source_dir $destination_dir > $test_dir/logs/$backup_date.log 2>&1 || \
  echo "rclone".$backup_date."failed!" >> $test_dir/logs/$backup_date.log

# To check difference between source dir and destination dir
/usr/local/bin/rclone check scripts/ google-drive:rclone_backup >> $test_dir/logs/$backup_date.log 2>&1
