#!/bin/bash

if ! . kaldi_asr_vars.sh; then
  echo "Failed to source kaldi_asr_vars.sh" 1>&2
  exit 1;
fi


# if all=true, then we will rebuild all versions, even versions that are not
# queued.

all=false
extract_all=false

if [ "$1" == "--all" ]; then
  all=true
  shift
fi

if [ "$1" == "--extract-all" ]; then
  extract_all=true
  all=true
  shift
fi

if [ $# -ne 0 ]; then
  echo "Usage: $0 [--all] [--extract-all]"
  echo "This script does all the building steps required after users have uploaded data."
  echo "By default it rebuilds just the build-numbers that were uploaded (nonempty"
  echo "QUEUED files in $data_root/submitted/<build-number>/), but if you supply the"
  echo "--all option it will rebuild all build-numbers."
  echo "Even with the --all option it won't re-extract the archives for the build-numbers"
  echo "that were not queued; to force re-extraction (which could take a while), you"
  echo "can specify --extract-all.  Be careful with --extract-all; if we somehow manually"
  echo "modified the already-extracted data, this will get overwritten if you use this"
  echo "option."
  exit 1;
fi

if $all; then
  if $extract_all; then
    log_message "processing all build indexes (including extracting previously-extracted archives)"
  else
    log_message "processing all build indexes (but not extracting previously-extracted archives)"
  fi
  if ! index_list=$(get_index_list.sh); then
    log_message "error getting index list"
    exit 1;
  fi
  for index in $index_list; do
    if $extract_all || [ -s $data_root/submitted/$index/QUEUED ]; then
      extract_opt=true
    fi
    if ! process_version.sh $extract_opt $index; then
      log_message "error processing build for index $index; terminating script."
      exit 1;
    fi
  done
else
  log_message "processing new build indexes"
  if ! index_list=$(get_index_list.sh --queued); then
    log_message "error getting index list"
    exit 1;
  fi
  if [ -z "$index_list" ]; then
    log_message "no new indexes to process"
  fi
  for index in $index_list; do
    if ! process_version.sh --extract $index; then
      log_message "error processing build for index $index: terminating script."
      exit 1;
    fi
  done
fi

if ! make_all_branches.sh; then
  log_message "error building branch indexes, terminating script."
  exit 1;
fi

if ! make_toplevel_index.sh; then
  log_message "error building top-level index, terminating script."
  exit 1;
fi

log_message "successfully built site."

exit 0;
