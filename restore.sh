#!/bin/sh

MOUNT_POINT="/mnt/windows"
KPRM_PATH="$MOUNT_POINT/KPRM/backup"
BACKUP_DATE=$(date +"%Y_%m_%d_%I_%M_%p")
LOG_FILE="/mnt/windows/kprm_restore_$BACKUP_DATE.txt"

function quit() {
 echo "Exit"
 cd /
 if [ -z "$1" ]; then
    umount "$1"
 fi
 exit 0
}

function restore_the_backup() {
    if [ -z "$1" -o ! -d "$KPRM_PATH/$1"  ]; then
      echo "Unknown folder $1"
      quit "$2"
    fi

    backup_path="$KPRM_PATH/$1"

    cd "$backup_path"

    echo -e "Restore hives in backup $1 at $BACKUP_DATE" | tee -a "$LOG_FILE"
    echo -e "" | tee -a "$LOG_FILE"
    echo -e "" | tee -a "$LOG_FILE"

    cp -Rfvb . ../../../ | tee -a "$LOG_FILE"

    echo -e "Restore Attributes" | tee -a "$LOG_FILE"
    echo -e "" | tee -a "$LOG_FILE"
    echo -e "" | tee -a "$LOG_FILE"

    hives_list=`find . -type f -name "*.dat" -print`

    cd ../../../

    for hive in "$hives_list"; do
        if [ -f "$hive" ]; then
          echo -e "Restore Attributes $hive" | tee -a "$LOG_FILE"
          setfattr -n system.ntfs_attrib_be -v 0x00000006 "$hive"| tee -a "$LOG_FILE"
        else
            echo -e "Hive $hive not found" | tee -a "$LOG_FILE"
        fi
    done

    echo -e "Restore Finish" | tee -a "$LOG_FILE"
    echo -e "Log is located in $LOG_FILE" | tee -a "$LOG_FILE"
    echo -e "" | tee -a "$LOG_FILE"
    echo -e "" | tee -a "$LOG_FILE"

    quit "$2"
}


umout /mnt/windows 2>/dev/null
mkdir -p /mnt/windows

devices=`fdisk -l | grep '^\/dev' | grep -i ntfs | expand | cut -d ' ' -f1`

for device in "$devices"; do
    mount -t ntfs "$device" "$MOUNT_POINT"
    cd /mnt/windows
    test -d "$KPRM_PATH"

    if [ "$?" -eq "0" ]; then
        cd "$KPRM_PATH"

        folders=`ls -ld */ | cut -d ' ' -f9 | tr -d "/"`
        choices=("${folders[@]}" "Quit")

        PS3="Which backup do you want to restore (write the number of the selected command)?"

        select folder in ${choices[@]}; do
           if [ "$folder" = "Quit" ]; then
             quit "$device"

           elif [ "$REPLY" -ge 1 -a "$REPLY" -le `ls -ld */ | wc -l` ]; then
                restore_the_backup "$folder" "$device"
                quit "$device"
           else
             echo "Bad Choice"
           fi
        done
    else
        cd /
        umount "$device"
    fi
done
