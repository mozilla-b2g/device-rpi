#!/bin/bash

export ANDROID_PRODUCT_OUT="out/target/product/$DEVICE"

function prepare_device_update {
    run_adb root &&
    run_adb shell stop b2g &&
    run_adb remount
    return $?
}

function resume_device {
    echo "Restarting B2G" &&
    run_adb shell start b2g
    return $?
}

function sync_partition { part=$1
    echo ""
    echo "Sync'ing '$part' partition to device ..."
    echo ""
    run_adb sync $part
    return $?
}

function sync_boot {
    echo ""
    echo "Sync'ing boot files to device ..."
    echo ""
    prepare_device_update &&
    echo run_adb shell mkdir -p /system/.boot &&
    echo run_adb shell mount /dev/block/mmcblk0p1 /system/.boot &&
    echo run_adb push $ANDROID_PRODUCT_OUT/boot /system/.boot &&
    echo run_adb shell umount /system/.boot &&
    echo run_adb shell rmdir /system/.boot &&
    echo run_adb reboot
    return $?
}

function flash_sdcard {
    echo ""
    echo "Partitioning, formatting, and flashing SD card ..."
    echo ""
    echo "Not yet implemented."
    return 1
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
            sync_boot
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
