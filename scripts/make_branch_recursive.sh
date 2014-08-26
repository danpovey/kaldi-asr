#!/bin/bash

function log_message {
  echo "$0: $*"
  echo "$0: $*" | logger -t kaldi-asr
}

if ! . kaldi_asr_vars.sh; then
  log_message "Failed to source kaldi_asr_vars.sh"
  exit 1;
fi

if [ $# -le 2 ]; then
  echo "Usage: $0 <branch-name> <directory-for-output> <list-of-corresponding-build-directories>"
  echo "e.g.: $0 trunk $data_root/tree.temp/trunk/egs/wsj $data_root/build/15/trunk/egs/wsj $data_root/build/19/trunk/egs/wsj $data_root/build/27/trunk/egs/wsj"
  echo "These must all correspond to different version-numbers of the same pathname,"
  echo "and at least one must be a directory and not a soft link (typically, all will be directories)."
  echo "None of the arguments may contain spaces."
  echo "The directory corresponding to the first argument does not need to exist."
  echo "This script is called recursively; the top-level call is in make_branch.sh."
  exit 1;
fi

branch=$1
outdir=$2
shift 2

n=$(echo $outdir | wc -w)
if ! [ $n -eq 1 ]; then
  log_message "Skipping directory $outdir because it seems to have spaces in it: $n"
  exit 0;  # This is not treated as an error; we want compilation to succeed anyway.
fi

# filter the inputs to include only those that are directories (and not soft links).
filtered_list=()
for x in $*; do
  if ! [ -S $x ] && [ -d $x ]; then  # x is not a soft link, and is a directory.
    filtered_list+=("$x");
  else
    log_message "Warning: ignoring $x because it is not a directory, or is a soft link."
  fi
done

if [ ${#filtered_list} -eq 0 ]; then
  log_message "error: none of the input arguments to $0 were directories (and not soft links): $outdir $*"
  exit 1;
fi

if ! mkdir -p $outdir; then
  log_message "error creating directory $outdir"
  exit 1;
fi


# make the index for this directory.
if ! php $script_root/make_branch_index.php $data_root $branch $outdir "${filtered_list[@]}" > $outdir/index.html; then
  log_message "error creating index for $outdir; php command was:"
  log_message php make_branch_index.php $data_root $branch $outdir "${filtered_list[@]}"
  exit 1;
fi


# below, we're listing all the subdirectories of @filtered_list (not the full
# pathnames, just the actual name of the subdirectory, e.g. 'log' or 'exp'),
# and 'uniq'ing them to get the names of all directories that are subdirectories
# of at least one of @filtered_list.
temp=$(mktemp /tmp/tmp.XXXXXX)
for dir in ${filtered_list[*]}; do
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
  args=("$branch" "$outdir/$subdir")
  for dir in ${filtered_list[*]}; do
    # add to @args all things of the form $dir/$subdir that
    # exist, and are directories and not soft links.
    if [ -d $dir/$subdir ] && [ ! -S $dir/$subdir ]; then 
      args+=("$dir/$subdir");
    fi
  done
  if [ ${#args} -lt 4 ]; then
    log_message "failed building branch index: none of ${filtered_list[*]} contains a subdirectory $subdir"
    exit 1;
  fi
  if ! make_branch_recursive.sh "${args[@]}"; then
    log_message "recursive call failed: make_branch_recursive.sh ${args[*]}"
    rm $temp
    exit 1;
  fi
done

rm $temp


exit 0;
