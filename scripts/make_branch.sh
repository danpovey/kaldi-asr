#!/bin/bash

if ! . kaldi_asr_vars.sh; then
  echo "Failed to source kaldi_asr_vars.sh" 1>&2
  exit 1;
fi

if [ $# -ne 1 ]; then
  echo "Usage: $0 <branch>"
  echo "e.g.: $0 trunk"
  echo "This script compiles the index for the specified branch; its output is in"
  echo "$data_root/tree/<branch>"
  exit 1;
fi

branch=$(echo $1 | sed s:/$::g)  # remove any trailing slashes from $branch.

case $branch in
  trunk)
;;
  branches/*)
;;
  sandbox/*)
;;
  *)
  echo "Invalid branch name: $branch, expected trunk or branches/* or sandbox/*"
  exit 1;
esac

temp_output=$data_root/tree.temp/$branch
final_output=$data_root/tree/$branch

if [ -d $temp_output ]; then
  log_message "temporary output directory $temp_output already exists, removing it."
  if ! rm -r $temp_output; then
    log_message "failed to remove temporary directory $temp_output";
    exit 1;
  fi
fi

mkdir -p $temp_output

# this script will be called recursively; it takes as arguments, the output
# location and then a list of build subdirectories build directories
# corresponding to a directory we want to build the index for.  The reason for
# doing it this way is that as we get deeper into the tree, we have to check
# fewer and fewer directories.

if ! index_list=$(get_index_list.sh); then
  log_message "failure getting index list."
  exit 1;
fi

if ! make_branch_recursive.sh $branch '' $index_list; then
  log_message "error calling make_branch_recursive.sh, command was: make_branch_recursive.sh $branch \"\" $index_list"
  exit 1;
fi

if [ -d $final_output ]; then
  rm -rf $final_output.delete  # just in case it already exists.
  if ! mv $final_output $final_output.delete; then
    log_message "error moving old tree location $final_output"
    exit 1;
  fi
fi

mkdir -p $(dirname $final_output) # make sure that the directory one up from $final_output exists,
                                   # e.g. the directory $data_root/tree/sandbox
if ! mv $temp_output $final_output || ! [ -f $final_output/index.html ]; then
  log_message "error moving temporary output to final location $final_output"  
  exit 1;
fi

rm -rf $final_output.delete  # just in case we previously moved the old tree there.


exit 0;
