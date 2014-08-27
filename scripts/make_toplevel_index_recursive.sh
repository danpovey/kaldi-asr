#!/bin/bash

if ! . kaldi_asr_vars.sh; then
  echo "Failed to source kaldi_asr_vars.sh" 1>&2
  exit 1;
fi

if [ $# -le 1 ]; then
  echo "Usage: $0 <relative-pathname> <branch1> <branch2> .. "
  echo "e.g.: $0 egs/wsj trunk sandbox/online sandbox/convnets branches/complete"
  echo "This script is called by make_toplevel_index.sh; it recursively compiles"
  echo "the toplevel index, with output in $data_root/all.temp"
  echo "note: <relative-pathname> may be the empty string."
  exit 1;
fi

relative_pathname=$1
shift
branches=$*  # list of all branches 


filtered_branches=() # get a list of branches that actually have something
                     # this location (determined by relative_pathname).

for branch in $branches; do
  if [ -d $data_root/tree/$branch/$relative_pathname ] && [ ! -S $data_root/tree/$branch/$relative_pathname ]; then
    filtered_branches+=($branch)
  fi
done

if [ ${#filtered_branches} -eq 0 ]; then
  log_message "no branches contained data at this location: $0 '$relative_pathname' $branches"
  exit 1;
fi


outdir=$data_root/all.temp/$relative_pathname

if ! mkdir -p $outdir; then
  log_message "error creating directory $outdir"
  exit 1;
fi

# make the index for this directory.
if ! php $script_root/make_toplevel_index.php $data_root "$relative_pathname" "${filtered_branches[@]}" > $outdir/index.html; then
  log_message "error creating index for $outdir; php command was:"
  log_message "php make_toplevel_index.php $data_root '$relative_pathname' ${filtered_branches[@]}"
  exit 1;
fi

# below, we're listing all the subdirectories present in any of the input
# locations in @filtered_branches.h: not the full pathnames, just the actual
# name of the subdirectory, e.g. 'log' or 'exp'), and 'uniq'ing them to get the
# names of all directories that are subdirectories of at least one of
# @filtered_branches
temp=$(mktemp /tmp/tmp.XXXXXX)
for branch in ${filtered_branches[@]}; do
  dir=$data_root/tree/$branch/$relative_pathname
  for x in $(ls -a $dir); do # -a option includes things that start with ".",
                             # which we also compile indexes for, although many
                             # such things will already have been filtered out
                             # in extract_build.sh (e.g. .svn, .backup).
    if [ -d $dir/$x ] && [ ! -S $dir/$x ] && [ "$x" != "." ] && [ "$x" != ".." ]; then 
      echo $x;  # $x is a directory and not a soft link, '.' or '..'
    fi 
  done
done | uniq >$temp || exit 1;

for subdir in $(cat $temp); do
  new_pathname=$(echo $relative_pathname/$subdir | sed s:^/::g) # remove leading slash.
  if ! make_toplevel_index_recursive.sh $new_pathname ${filtered_branches[@]}; then
    log_message "recursive call failed: make_toplevel_index_recursive.sh $new_pathname ${filtered_branches[@]}"
    rm $temp
    exit 1;
  fi
done

rm $temp


exit 0;
