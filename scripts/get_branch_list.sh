#!/bin/bash

if ! . kaldi_asr_vars.sh; then
  echo "Failed to source kaldi_asr_vars.sh" 1>&2
  exit 1;
fi

if [ $# -ne 0 ]; then
  echo "Usage: $0 > <branch-list-file>"
  echo "e.g.: $0 > /tmp/branch_list"
  echo "This script will find a list of all the branch names (things of the form 'trunk',"
  echo "'sandbox/*', or 'branches/*') that appear as subdirectories in $data_root/build/<numeric-subdirectories>,"
  echo "and print them to the stdout.  This is needed in order to build the indexes for the branches."
  exit 1;
fi

temp=$(mktemp /tmp/tmp.XXXXXX)

for subdir in $data_root/build/[0-9]*; do
  if [ -d $subdir/trunk ]; then echo trunk; fi;
  for sandbox_or_branches in sandbox branches; do
    if [ -d $subdir/$sandbox_or_branches ]; then 
      for x in $(ls $subdir/$sandbox_or_branches); do 
        if [ -d $subdir/$sandbox_or_branches/$x ]; then echo $x; fi
      done
    fi
  done
done > $temp || exit 1;

sort $temp | uniq

rm $temp

exit 0;
