#!/bin/sh

umout /mnt/windows 2>/dev/null
mkdir -p /mnt/windows

devices=`fdisk -l | grep '^\/dev' | grep -i ntfs | expand | cut -d ' ' -f1`


for device in "$devices"; do
    mount -t ntfs "$device" /mnt/windows
    cd /mnt/windows
    test -d KPRM/backup

    if [ "$?" -eq "0" ]; then
        cd KPRM/backup

        folders=`ls -ld */ | cut -d ' ' -f9 | tr -d "/"`
        choices=("${folders[@]}" "Quit")

        PS3="Which backup do you want to restore (write the number or 'Q' for exit)?"
        select folder in ${choices[@]};
        do
           if [ "$folder" = "Quit" ]; then
             echo "Exit"
             cd /
             umount "$device"
             exit 0
           elif [ "$REPLY" -ge 1 -a "$REPLY" -le `ls -ld */ | wc -l` ]; then
                echo "Restore $folder"
           else
             echo "bad choice"
           fi
        done
    else
        cd /
        umount "$device"
    fi
done
