#!/bin/bash

function log_message {
  echo "$0: $*"
  echo "$0: $*" | logger -t kaldi-asr
}

if ! . kaldi_asr_vars.sh; then
  log_message "Failed to source kaldi_asr_vars.sh"
  exit 1;
fi

if [ $# -ne 1 ] || ! [ "$1" -gt 0 ]; then
  echo "Usage: $0 <build-number>"
  echo "e.g.: $0 15"
  echo "This script, which should be called after extract_build.sh, will make a directory tree"
  echo "in $data_root/build_index/<build-number>.temp that has the same structure as the directory"
  echo "tree in $data_root/build/<build-number>.temp, but without the files- only a file named size_kb"
  echo "that contains (as text) the integer number of kilobytes in that directory (inclusive)."
  echo "This will be used while building the indexes (see make_indexes.sh)."
  exit 1;
fi

build=$1

# First extract the data into a temporary directory.

srcdir=$data_root/build/$build
destdir=$data_root/build_index/$build.temp

if [ ! -d $srcdir ]; then
  log_message "No such directory $srcdir"
  exit 1;
fi
if [ -d $destdir ]; then
  log_message "destination directory $destdir already exists; removing it."
  if ! rm -r $destdir; then
    log_message "error removing $destdir"
    exit 1;
  fi
fi

cd $srcdir

error=false


# the awk command filters out any directory names with
# spaces in them: we simply won't process these.

if ! du -k | awk '(NF == 2)' | (
  # the set -e will cause the sub-shell to exit with error if any of the commands below fail,
  # e.g. if the disk is full, so we can detect it from the outer shell.
  set -e;
  while read size directory; do
    mkdir -p $destdir/$directory
    echo $size > $destdir/$directory/size_kb
  done
); then
  log_message "Error creating directory tree with sizes in $destdir"
  exit 1;
fi

log_message "Successfully created directory tree in $destdir"

exit 0;
