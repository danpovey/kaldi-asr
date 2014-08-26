#!/bin/bash

if ! . kaldi_asr_vars.sh; then
  log_message "Failed to source kaldi_asr_vars.sh"
  exit 1;
fi

if [ $# -ne 0 ]; then
  echo "Usage: $0 > <build-index-list-file>"
  echo "e.g.: $0 > /tmp/index_list"
  echo "This script will print a list of all the build-index values that"
  echo "currently exist, e.g. '1 2 4 5 6 7', but one on each line"
  exit 1;
fi

temp=$(mktemp /tmp/tmp.XXXXXX)

for x in $(ls $data_root/build/ | grep -E '^[0-9]+$'); do
  if [ -d $data_root/build/$x ]; then
    echo $x
  fi
done

exit 0;
