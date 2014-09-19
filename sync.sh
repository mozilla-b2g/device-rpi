#!/usr/bin/env bash

BUILD="out/target/product/rpi"

function error { msg="$@";
    echo $msg >&2
}

function fail { msg="$@";
    error $msg "- exiting"
    exit 1
}

./mount.sh || fail "Couldn't mount disk"
./flash.sh || fail "Couldn't flash image"
./unmount.sh || fail "Couldn't unmount disk"
