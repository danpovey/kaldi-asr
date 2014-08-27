#!/bin/bash -v

if [ $(id -u) != 0 ]; then
  echo This script must be run as root
  exit 1
fi

set -e
cd /var/www/kaldi-asr
if [ ! -f loopback_file ]; then
  # 3 gigabyte file.
  dd if=/dev/zero of=loopback_file bs=1024 count=$[1024*1024*3]
  chmod 600 loopback_file
fi

if ! losetup /dev/loop1; then  # not previously set up.
  losetup /dev/loop1 /var/www/kaldi-asr/loopback_file
  mkfs -t ext3 /dev/loop1
fi

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

mkdir -p /mnt/kaldi-asr/tmp
rm tmp.large
ln -s /mnt/kaldi-asr/tmp tmp.large

for x in tmp.small tmp.large; do
  chown -R www-data:www-data $x
  chmod 600 $x
done
