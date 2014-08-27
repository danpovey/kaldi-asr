#!/bin/bash

if ! . kaldi_asr_vars.sh; then
  echo "Failed to source kaldi_asr_vars.sh" 1>&2
  exit 1;
fi

extract=false
if [ "$1" == "--extract" ]; then
  extract=true
  shift
fi

if [ $# -ne 1 ] || ! [ "$1" -gt 0 ]; then
  echo "Usage: $0 [--extract] <version-number>"
  echo "e.g.: $0 --extract 15"
  echo "This script will process the data in $root/submitted/<version-number>"
  echo "with output in $data_root/build/<version-number>.  But it will only do the"
  echo "data-extraction part (un-tarring the archive) if you use the"
  echo "--extract option."
  exit 1;
fi

set -e
if $extract; then
  extract_build.sh $1
fi
make_version_index_tree.sh $1
make_version_index.sh $1
log_message "successfully processed build $1"

exit 0;
