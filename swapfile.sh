#!/bin/bash
SWAP_SIZE_MEGABYTES=2048
if [ $SWAP_SIZE_MEGABYTES -eq 0 ];then
        echo No swap size given, skipping.
else
        if [ -e /swapfile ];then
                echo /swapfile already exists, skiping.
        else
                echo Creating /swapfile of $SWAP_SIZE_MEGABYTES Megabytes
                dd if=/dev/zero of=/swapfile bs=1024 count=$(($SWAP_SIZE_MEGABYTES*1024))
                mkswap /swapfile
                swapon /swapfile
                echo Swap Status:
                swapon -s
        fi
fi
