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
  echo "currently exist, e.g. '1 2 4 5 6 7', but one on each line"
  echo "With the --queued option, it will print only those build-index"
  echo "values for which a nonempty QUEUED file exists (meaning, the data"
  echo "has been uploaded but not yet processed)."
  exit 1;
fi

temp=$(mktemp /tmp/tmp.XXXXXX)

for x in $(ls $data_root/build/ | grep -E '^[0-9]+$'); do
  if ! $queued; then # get all build numbers that exist.
    if [ -d $data_root/build/$x ]; then
      echo $x
    fi
  else # only print of the QUEUED file is nonempty; this means it is
       # queued to be built.
    if [ -s $data_root/build/$x/QUEUED ]; then
      echo $x
    fi
  fi
done

exit 0;
