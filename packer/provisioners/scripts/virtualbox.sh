#!/bin/bash

yum -y install \
    bzip2 \
    kernel-devel

VBOX_VERSION=$(cat "$HOME/.vbox_version")
GUEST_ADDITIONS_ISO_PATH="$HOME/VBoxGuestAdditions_$VBOX_VERSION.iso"
MOUNTPOINT=/mnt/vbox-guest-cd

mkdir "$MOUNTPOINT"
mount -o loop "$GUEST_ADDITIONS_ISO_PATH" "$MOUNTPOINT"

sh "$MOUNTPOINT"/VBoxLinuxAdditions.run

umount "$MOUNTPOINT"
rm -f "$GUEST_ADDITIONS_ISO_PATH"
