#!/bin/bash

if ! . kaldi_asr_vars.sh; then
  echo "Failed to source kaldi_asr_vars.sh" 1>&2
  exit 1;
fi

if [ $# -ne 0 ]; then
  echo "Usage: $0"
  echo "This script creates the toplevel index in $data_root/all/, which contains"
  echo "pointers to the indexes of the individual branches."
  exit 1;
fi

if ! branch_list=$(get_branch_list.sh); then
  log_message "error getting branch list.";
  exit 1;
fi
if [ -z "$branch_list" ]; then
  log_message "empty branch list"
  exit 1;
fi
tempdir=$data_root/all.temp
destdir=$data_root/all

if [ -d $tempdir ]; then
  log_message "removing old directory $data_root/all.temp"
  if ! rm -r $data_root/all.temp; then
    log_message "error removing old directory $data_root/all.temp"
    exit 1;
  fi
fi

# this script knows to put its output in $data_root/all.temp
if ! make_toplevel_index_recursive.sh '' $branch_list; then
  log_message "error compiling toplevel index."
  exit 1;
fi

deldir=$data_root/all.to_delete
if [ -d $deldir ]; then
  log_message "removing old directory $data_root/all.to_delete"
  if ! rm -r $deldir; then
    log_message "error removing old directory $data_root/all.to_delete"
    exit 1;
  fi
fi
if [ -e $destdir ]; then
  if ! mv $destdir $deldir; then
    log_message "error moving $destdir to $deldir"
    exit 1;
  fi
fi

if ! mv $tempdir $destdir; then
  log_message "error moving $tempdir to $destdir"
  exit 1;
fi

if [ -e $deldir ] && ! rm -r $deldir; then
  log_message "error deleting $deldir"
  exit 1;
fi

log_message "successfully compiled top-level index."

exit 0;
