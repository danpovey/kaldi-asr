#!/bin/bash

if ! . kaldi_asr_vars.sh; then
  echo "Failed to source kaldi_asr_vars.sh" 1>&2
  exit 1;
fi

if [ $# -le 2 ]; then
  echo "Usage: $0 <branch-name> <relative-pathname> <list-of-build-indexes>"
  echo "e.g.: $0 trunk egs/wsj 15 19 27"
  echo "This script is called recursively; the top-level call is in make_branch.sh."
  exit 1;
fi

branch=$1
relative_pathname=$2 # will be the empty string at the top level.
shift 2

build_indexes=$*

# filter the inputs to include only those that are directories (and not soft links).
filtered_indexes=()
for b in $build_indexes; do
  dir=$data_root/build/$b/$branch/$relative_pathname
  dir=$(echo $dir | sed s:/$::g) # remove trailing slashes.
  if ! [ -S $dir ] && [ -d $dir ]; then  # x is not a soft link, and is a directory.
    filtered_indexes+=("$b");
  fi
done

if [ ${#filtered_indexes} -eq 0 ]; then
  # this should not happen
  log_message "error: filtered out all input indexes."
  exit 1;
fi

outdir=$data_root/tree.temp/$branch/$relative_pathname

if ! mkdir -p $outdir; then
  log_message "error creating directory $outdir"
  exit 1;
fi


# make the index for this directory.  be careful; $relative_pathname may be the empty string.
if ! php $script_root/make_branch_index.php $data_root $branch "$relative_pathname" "${filtered_indexes[@]}" > $outdir/index.html; then
  log_message "error creating index for $outdir; php command was:"
  log_message php make_branch_index.php $data_root $branch \"$relative_pathname\" "${filtered_indexes[@]}"
  exit 1;
fi


# below, we're listing all the subdirectories of @filtered_list (not the full
# pathnames, just the actual name of the subdirectory, e.g. 'log' or 'exp'),
# and 'uniq'ing them to get the names of all directories that are subdirectories
# of at least one of @filtered_list.
temp=$(mktemp /tmp/tmp.XXXXXX)
for b in ${filtered_indexes[@]}; do
  dir=$data_root/build/$b/$branch/$relative_pathname
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
  if ! make_branch_recursive.sh $branch $new_pathname ${filtered_indexes[@]}; then
    log_message "recursive call failed: make_branch_recursive.sh $branch $new_pathname ${filtered_indexes[@]}"
    rm $temp
    exit 1;
  fi
done

rm $temp


exit 0;
