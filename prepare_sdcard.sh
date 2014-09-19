#!/bin/bash

function error { msg="$@";
    echo $msg >&2
}

function fail { msg="$@";
    error $msg "- exiting"
    exit 1
}

disk=${1:-"/dev/mmcblk0"}

if [ ! -b $disk ]; then
    fail "Disk '$disk' doesn't exist or isn't a block device"
fi

dd bs=1K count=1 if=$disk of=/dev/null || fail "Can't read $disk; are you running as superuser?"

echo -e "\nPreparing to partition and form $disk ..."
echo -e "\n\n***** WARNING WARNING WARNING *****\n\n"
echo -e "**ALL DATA** on $disk will be PERMANENTLY ERASED.\n\n"

read -p "Are you sure you want to do this? [YES/no] " reply
if [ "YES" != "$reply" ]; then
    echo "OK, goodbye."
    exit 1
fi

#sfdisk $disk < fxpi.sfdisk || fail "Couldn't partition $disk"

sfdisk $disk <<EOF || fail "Couldn't partition $disk"
# Sectors of 512 bytes
unit: sectors

# Format is
#
# <start>,<size>,<Id>
#

# boot partition
#
# Contains the VideoCore firmware, ARM loader, kernel image, and
# various configuration options.  The VideoCore bootloader requires
# the partition to be partition 1 and vfat.
#
# 50 MiB
#
8192,102400,e

# root
#
# Contains the init program and basic system configuration.  From here
# on, the partition table looks like a pretty standard android system.
#
# 5 MiB
#
112640,10240,83

# system. 500 MiB
124928,1024000,83

# (extended partition for remaining partitions)
1150976,+,85

# data. 1434 MiB
1153024,2936832,83

# cache. 50MiB
4091904,102400,83

# sdcard
#
# Contains media files, mostly.  We want any host to be able to mount
# this partition, so we choose vfat for maximum compatibility.
#
# Expands to fill remaining free space.
#
4196352,+,c
EOF

mkfs -t vfat -n BOOT ${disk}p1
mkfs -t ext4 -L root ${disk}p2
mkfs -t ext4 -L system ${disk}p3
mkfs -t ext4 -L data ${disk}p5
mkfs -t ext4 -L cache ${disk}p6
mkfs -t vfat -n SDCARD ${disk}p7
