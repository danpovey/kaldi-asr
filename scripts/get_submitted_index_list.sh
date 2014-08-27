#!/bin/bash

if ! . kaldi_asr_vars.sh; then
  log_message "Failed to source kaldi_asr_vars.sh"
  exit 1;
fi

queued=false
if [ "$1" == "--queued" ]; then
  queued=true
  shift
fi

if [ $# -ne 0 ]; then
  echo "Usage: $0 [--queued] > <build-index-list-file>"
  echo "e.g.: $0 > /tmp/index_list"
  echo "This script will print a list of all the build-index values that"
  echo "have been submitted until now; with the --queued option it will "
  echo "only print those that have a nonempty QUEUED file."
  exit 1;
fi

temp=$(mktemp /tmp/tmp.XXXXXX)

for x in $(ls $data_root/submitted/ | grep -E '^[0-9]+$'); do
  if [ -d $data_root/submitted/$x ]; then
    if ! $queued || [ -s $data_root/submitted/$x/QUEUED ]; then
      echo $x
    fi
  fi
done

exit 0;
