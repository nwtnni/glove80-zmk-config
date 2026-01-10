#!/usr/bin/env bash

set -o pipefail
set -o errexit
set -o nounset

# https://stackoverflow.com/a/246128
readonly ROOT=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

flash() {
    local -r disk="/dev/disk/by-id/usb-Adafruit_nRF_UF2_GLV80-$2-0:0"
    local -r mount="$ROOT/mount-$2"

    echo "[$2] Waiting for bootloader device..."
    until [[ -b "$disk" ]]; do
        sleep 1
    done

    echo "[$2] Copying firmware ($1)..."

    mkdir -p "$mount"
    sudo mount "$disk" "$mount"
    sudo cp "$1" "$mount"

    echo "[$2] Waiting for flashing to complete..."
    until [[ ! -b "$disk" ]]; do
        sleep 1
    done

    sudo umount "$mount"
    rmdir "$mount"
    echo "[$2] Done!"
}

cd "$ROOT"

./build.sh
flash "./glove80.uf2" "$SERIAL_LHS" &
flash "./glove80.uf2" "$SERIAL_RHS" &
wait
