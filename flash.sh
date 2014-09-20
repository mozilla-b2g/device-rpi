#!/bin/bash

export ANDROID_PRODUCT_OUT="out/target/product/$DEVICE"

KERNEL_IMG=${KERNEL_IMG:-$DEVICE_DIR/prebuilt/kernel.img}

function prepare_device_update {
    run_adb root &&
    run_adb shell stop b2g &&
    run_adb remount
    return $?
}

function prepare_boot_update {
    prepare_device_update &&
    run_adb shell mkdir -p /system/.boot &&
    run_adb shell mount -t vfat /dev/block/mmcblk0p1 /system/.boot
    return $?
}

function resume_device {
    echo "Restarting B2G" &&
    run_adb shell start b2g
    return $?
}

function finish_boot_update {
    run_adb shell umount /system/.boot &&
    run_adb shell rmdir /system/.boot &&
    echo "Rebooting device ..." &&
    run_adb reboot
    return $?
}

function sync_partition { part=$1
    echo ""
    echo "Sync'ing '$part' partition to device ..."
    echo ""
    run_adb sync $part
    return $?
}

function push_boot {
    echo ""
    echo "Pushing boot files to device ..."
    echo ""
    run_adb push $ANDROID_PRODUCT_OUT/boot /system/.boot
    return $?
}

function push_kernel {
    echo ""
    echo "Pushing kernel to device ..."
    echo ""
    run_adb push $KERNEL_IMG /system/.boot/kernel.img
    return $?
}

function flash_sdcard {
    echo ""
    echo "Partitioning, formatting, and flashing SD card ..."
    echo ""
    echo "A full flash of a Raspberry Pi build works a bit differently"
    echo "than a full flash of most other devices.  You will insert an SD"
    echo "card that will be prepared with your b2g build."
    echo ""
    echo "Your SD card must have a capacity of AT LEAST 4GB.  This script"
    echo "DOES NOT CHECK your SD card capacity."
    echo ""
    echo "Ensure that your SD card *IS NOT* inserted currently."
    echo ""
    read -p "Press Enter when you've ensured it's not inserted. "
    echo ""

    devices_before=$(ls /dev | sort | tr '\n' ' ')

    echo "Please insert your SD card now."
    echo ""
    read -p "Press Enter when you've finished inserting it. "
    echo ""

    devices_after=$(ls /dev | sort | tr '\n' ' ')

    for dev in $devices_after; do
        tmp="$devices_before"
        devices_before=${devices_before#$dev }
        if [ "$tmp" == "$devices_before" ]; then
            break
        fi
    done
    if [ "" == "$devices_before" ]; then
        echo "Sorry, couldn't find newly-inserted SD card.  Please try again."
        return 1
    fi

    disk="/dev/$dev"
    echo "Detected newly-added device"
    echo ""
    echo "  $disk"
    echo ""
    if [ ! -b $disk ]; then
        echo "'$disk' isn't a block device, so isn't an SD card.  Bailing."
        return 1
    fi
    echo "Please double-check that this device is your SD card."
    echo ""
    echo "**************************************************"
    echo "THIS PROCESS WILL DESTROY ALL DATA ON $disk, PERMANENTLY!"
    echo ""
    echo "BE VERY VERY CAREFUL: if this device IS NOT your SD card, then"
    echo "you can DESTROY YOUR ENTIRE HARD DRIVE!!!"
    echo "**************************************************"
    echo ""
    echo "When you're absolutely certain that $disk is your SD card,"
    read -p "please type \"I'm sure\" to continue. > " answer
    echo ""

    if [ "$answer" != "I'm sure" ]; then
        echo "OK, bailing out."
        return 1
    fi

    dd bs=1K count=1 if=$disk of=/dev/null
    result=$?
    if [[ $result != 0 ]]; then
        echo "Can't read $disk; are you running as superuser?"
        return $result
    fi

    echo "Partitioning $disk ..."
    echo ""
    sfdisk -uS $disk <<EOF
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
    result=$?
    if [[ $result != 0 ]]; then
        echo "Failed to partition $disk.  Bailing."
        echo ""
        echo "This is known to fail on occasion with an error like"
        echo ""
        echo "sfdisk: BLKRRPART: Device or resource busy"
        echo "sfdisk: The command to re-read the partition table failed."
        echo ""
        echo "If you see an error like this, try re-running this script."

        return 1
    fi
    echo "... finished partitioning $disk."
    echo ""

    BOOT_PART=${disk}p1
    ROOT_PART=${disk}p2
    SYSTEM_PART=${disk}p3
    DATA_PART=${disk}p5
    CACHE_PART=${disk}p6
    SDCARD_PART=${disk}p7

    echo "Formatting partitions on $disk ..."
    echo ""
    mkfs -t vfat -n BOOT $BOOT_PART &&
    mkfs -t ext4 -L root $ROOT_PART &&
    mkfs -t ext4 -L system $SYSTEM_PART &&
    mkfs -t ext4 -L data $DATA_PART &&
    mkfs -t ext4 -L cache $CACHE_PART &&
    mkfs -t vfat -n SDCARD $SDCARD_PART &&
    result=$?
    if [[ $result != 0 ]]; then
        echo "Failed to format partitions on $disk.  Bailing."
        return $result
    fi
    echo "... finished formatting partitions on $disk."
    echo ""

    echo "Flashing operating system onto $disk ..."
    echo ""
    mkdir -p .mnt/boot &&
    mount $BOOT_PART .mnt/boot &&
    mkdir -p .mnt/root &&
    mount $ROOT_PART .mnt/root &&
    mkdir -p .mnt/system &&
    mount $SYSTEM_PART .mnt/system &&
    mkdir -p .mnt/data &&
    mount $DATA_PART .mnt/data
    # 'cache' is a newly-created file system, which is the state we
    # want it in.  So nothing to do for it.
    #
    # We don't care about the contents of 'sdcard'.  Empty is fine.
    result=$?
    if [[ $result != 0 ]]; then
        echo "Failed to mount $disk partitions locally.  Bailing."
        return $result
    fi

    for mnt in boot root system data; do
        special_flags=""
        if [ "boot" == "$mnt" ]; then
            # 'boot' is a special vfat snowflake.
            special_flags="--no-o --no-g --no-p"
        fi
        rsync -av $special_flags $ANDROID_PRODUCT_OUT/$mnt/ .mnt/$mnt/ &&
        umount .mnt/$mnt &&
        sleep 1 &&
        rmdir .mnt/$mnt
        result=$?
        if [[ $result != 0 ]]; then
            echo "Failed to flash $mnt files.  Bailing."
            return $result
        fi
    done
    rmdir .mnt
    echo "... finished flashing OS onto $disk."
    echo ""

    echo "Done!  You may eject your SD card now and run b2g."
    return 0
}

function flash_rpi { project=$1
    case "$project" in
    "system"|"data")
            prepare_device_update &&
            sync_partition $project &&
            resume_device
            return $?
            ;;
    "boot")
            prepare_boot_update &&
            push_boot &&
            finish_boot_update
            return $?
            ;;
    "kernel")
            prepare_boot_update &&
            push_kernel &&
            finish_boot_update
            return $?
            ;;
    "")
            if $FULLFLASH; then
                flash_sdcard
            else
                prepare_device_update &&
                sync_partition "system" &&
                flash_gaia &&
                update_time &&
                resume_device
            fi
            return $?
            ;;
    *)
            echo "Sorry, unrecognized project '$project'."
            return 1
            ;;
    esac
}
