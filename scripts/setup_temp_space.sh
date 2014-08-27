#!/bin/bash -v

if [ $(id -u) != 0 ]; then
  echo This script must be run as root
  exit 1
fi

# first remove any existing loop devices
for device in $(losetup -a | grep loopback_file | awk '{print $1}'); do
  losetup -d $device
done

for device $(losetup -a); do 
  echo Was expecting other loopback devices to exist: device $device exists.
  exit 1;
done

set -e
cd /var/www/kaldi-asr

if [ ! -f loopback_file ]; then
  # 3 gigabyte file.
  dd if=/dev/zero of=loopback_file bs=1024 count=$[1024*1024*3]
  chmod 600 loopback_file
fi

losetup /dev/loop0 /var/www/kaldi-asr/loopback_file
mkfs -t ext3 /dev/loop0


mkdir -p /mnt/kaldi-asr-loopback
rm tmp.small
ln -s /mnt/kaldi-asr-loopback tmp.small

if ! grep kaldi-asr-loopback /etc/fstab; then
  echo "/dev/loop0 /mnt/kaldi-asr-loopback ext3 loop,noauto 0 0" >>/etc/fstab
fi

if ! mount | grep kaldi-asr-loopback; then
  mount /mnt/kaldi-asr-loopback
fi

if ! [ -e /mnt/kaldi-asr-loopback/lost+found ]; then
  echo "error: not properly mounted"
  exit 1;
fi

rm tmp.small
ln -s /mnt/kaldi-asr-loopback tmp.small

mkdir -p /mnt/kaldi-asr/tmp
rm tmp.large
ln -s /mnt/kaldi-asr/tmp tmp.large

for x in tmp.small tmp.large; do
  chown -R www-data:www-data $x
  chmod 600 $x
done
