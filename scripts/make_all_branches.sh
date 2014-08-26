#!/bin/bash

function log_message {
  echo "$0: $*"
  echo "$0: $*" | logger -t kaldi-asr
}

if ! . kaldi_asr_vars.sh; then
  log_message "Failed to source kaldi_asr_vars.sh"
  exit 1;
fi

if [ $# -ne 0 ]; then
  echo "Usage: $0"
  echo "This script calls make_branch.sh on all the branches present, which list is determined"
  echo "from get_branch_list.sh."
  exit 1;
fi

if ! branch_list=$(get_branch_list.sh); then
  log_message "error getting branch list.";
  exit 1;
fi

for branch in $branch_list; do
  if ! make_branch.sh $branch; then
    log_message "failed to compile branch $branch"
    exit 1;
  fi
done

log_message "successfully compiled all branch indexes."

exit 0;
