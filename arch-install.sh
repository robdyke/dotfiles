#!/bin/bash
read -e -p "Target device: " device

if [ ! -b $device ]; then
    >&2 echo "$device is not a block device"
    exit 1
fi

read -e -p "Hostname: " hostname
read -e -p "Username: " username
read -e -s -p "User / FDE Password: " passwd

# partition disk

# TODO commands piped into fdisk or sfdisk which is a scripted fdisk
# https://superuser.com/questions/332252/how-to-create-and-format-a-partition-using-a-bash-script
# https://en.wikipedia.org/wiki/Partition_type

# mount partitions
# generate fstab
# set hostname
# create user account
# install base (chroot)
# provision (chroot)
