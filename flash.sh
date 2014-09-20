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
