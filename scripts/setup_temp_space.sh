#!/bin/bash -v

if [ $(id -u) != 0 ]; then
  echo This script must be run as root
  exit 1
fi

set -e
cd /var/www/kaldi-asr
# 3 gigabyte file.
dd if=/dev/zero of=loopback_file bs=1024 count=$[1024*1024*3]
chmod 600 loopback_file

losetup /dev/loop1 /var/www/kaldi-asr/loopback_file

mkfs -t ext3 /dev/loop1

mkdir -p /mnt/kaldi-asr-loopback
rm tmp.small
ln -s /mnt/kaldi-asr-loopback tmp.small

if ! grep kaldi-asr-loopback /etc/fstab; then
  echo "/dev/loop1 /mnt/kaldi-asr-loopback ext3 loop,noauto 0 0" >>/etc/fstab
fi
mount /mnt/kaldi-asr-loopback

if ! [ -e /mnt/kaldi-asr-loopback/lost+found ]; then
  echo "error: not properly mounted"
  exit 1;
fi

chmod a+rwx tmp.small/
