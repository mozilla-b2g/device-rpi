#!/usr/bin/env bash

PRODUCT_OUT="out/target/product/rpi"

function error { msg="$@";
    echo $msg >&2
}

function fail { msg="$@";
    error $msg "- exiting"
    exit 1
}

for mnt in root system data; do
    rsync -av --delete $PRODUCT_OUT/$mnt/ mnt/$mnt/ || fail "Couldn't sync $mnt"
done

# Sync firmware, kernel image, and VideoCore configs.
rsync -av --delete prebuilt/ mnt/boot/

# Blow away /cache
rm -rf cache/*
