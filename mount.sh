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

mkdir -p mnt/boot
mount ${DISK}p1 mnt/boot || fail "Couldn't mount boot/"

mkdir -p mnt/root
mount ${DISK}p2 mnt/root || fail "Couldn't mount /"

mkdir -p mnt/system
mount ${DISK}p3 mnt/system || fail "Couldn't mount /"

mkdir -p mnt/data
mount ${DISK}p5 mnt/data || fail "Couldn't mount /data"

mkdir -p mnt/cache
mount ${DISK}p6 mnt/cache || fail "Couldn't mount /cache"

mkdir -p mnt/sdcard
mount ${DISK}p7 mnt/sdcard || fail "Couldn't mount /sdcard"
