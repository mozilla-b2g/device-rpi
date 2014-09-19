#!/usr/bin/env bash

DISK="/dev/mmcblk0"

function error { msg="$@";
    echo $msg >&2
}

function fail { msg="$@";
    error $msg "- exiting"
    exit 1
}

if [ ! -b $DISK ]; then
    fail "Disk '$DISK' doesn't exist or isn't a block device"
fi


for mnt in boot root system data cache sdcard; do
    # Keep going on failure.
    umount mnt/$mnt
done
