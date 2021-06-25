#!/usr/bin/bash

/usr/local/bin/rclone sync -i $1 google-drive:rclone_backup --verbose

