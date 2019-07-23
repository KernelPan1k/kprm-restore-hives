#!/bin/sh

umout /mnt/windows 2>/dev/null
mkdir -p /mnt/windows

devices=`fdisk -l | grep '^\/dev' | grep -i ntfs | expand | cut -d ' ' -f1`


for device in "$devices"; do
    mount -t ntfs "$device" /mnt/windows
    cd /mnt/windows
    test -d KPRM/backup

    if [ "$?" -eq "0" ]; then
        list_backup=`ls -md */`
    else
        cd /
        umount "$device"
    fi
done
