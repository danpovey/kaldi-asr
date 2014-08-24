#!/bin/bash

#data_root=/mnt/kaldi-asr-data
data_root=/Users/danielpovey/kaldi-asr/data

if [ $# -ne 1 ] || ! [ "$1" -gt 0 ]; then
  echo "Usage: $0 <build-number>"
  echo "e.g.: $0 15"
  echo "This script will extract the data in $data_root/submitted/<build-number> into $data_root/build/<build-number>"
  echo "with output in $data_root/build/<build-number>"
  exit 1;
fi

build=$1

function log_message {
  echo "$0: $*"
  echo "$0: $*" | logger -t kaldi-asr
}


# First extract the data into a temporary directory.

tmpdir=$data_root/build/$build.temp
destdir=$data_root/build/$build

if [ -d $tmpdir ]; then
  log_message "removing old copy of temporary directory $tmpdir (perhaps a broken run?)";
  rm -r $tmpdir || exit 1;
fi

if ! mkdir $tmpdir; then
  log_message "error creating temporary directory $tmpdir"
  exit 1;
fi

sub=$data_root/submitted/$build/

if [ ! -f $sub/metadata ]; then
  log_message "No such file $sub/metadata"
  exit 1;
fi

if [ ! -f $sub/archive.tar.gz ]; then
  log_message "No such file $sub/archive.tar.gz"
  exit 1;
fi


# source a command like 'branch=trunk', so we set the variable.
eval `grep '^branch=' $sub/metadata`;

# source a command like 'root=egs/wsj', so we set the variable.
eval `grep '^root=' $sub/metadata`;

extraction_root=$tmpdir/$branch/$root/
if ! mkdir -p $extraction_root; then
  log_message "failed to create directory $extraction_root"
  exit 1;
fi

if ! tar -C $extraction_root -xf $sub/archive.tar.gz; then
  log_message "failed to extract data."
  exit 1;
fi

log_message "successfully extracted data to $extraction_root"

if [ -d $destdir ]; then
  log_message "removing old copy of processed data, in $destdir"
  if ! rm -r $destdir; then
    log_message "error removing old data directory $destdir"
    exit 1;
  fi
fi

if ! mv $tmpdir $destdir; then
  log_message "error moving directory $tmpdir to $destdir"
  exit 1;
fi

exit 0;
