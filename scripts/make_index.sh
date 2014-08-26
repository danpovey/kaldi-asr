#!/bin/bash

if ! . kaldi_asr_vars.sh; then
  echo "Failed to source kaldi_asr_vars.sh" 1>&2
  exit 1;
fi

if [ $# -ne 1 ] || ! [ "$1" -gt 0 ]; then
  echo "Usage: $0 <build-number>"
  echo "e.g.: $0 15"
  echo "This script, which should be called after make_index_tree.sh, will create index.html files"
  echo "in subdirectories of $data_root/build_index/<build-number>.temp, and when done,"
  echo "will move the directory tree to $data_root/build_index/<build-number> after removing"
  echo "any existing directory with that name.  This script also examines the contents of"
  echo "$data_root/build_indexes/<build-number> while creating the index."
  exit 1;
fi

build=$1


srcdir=$data_root/build/$build
metadata=$data_root/submitted/$build/metadata
dir=$data_root/build_index/$build.temp

for f in $dir/size_kb $metadata; do
  [ ! -s $f ] && log_message "Expeced file $f to exist (and be nonempty)" && exit 1;
done

for x in $(find $dir -type d); do
  if [ ! -d $x ]; then # could occur, for example, if directory names have spaces in them.
                       # this won't be a fatal error.
    log_message "Skipping directory $dir as it does not seem to exist (perhaps dirnames with spaces?)"
    continue
  fi

  x_src=$(echo $x | sed s:^$dir:$srcdir:);
  if [ -z "$x_src" ] || [ "$x_src" == "$x" ]; then
    log_message "Error getting source for directory '$x', got '$x_src'"
    exit 1;
  fi
  if [ ! -d "$x_src" ]; then
    log_message "Error: source directory $x_src for directory $x does not exist."
    exit 1;
  fi
  if [ ! -s $x/size_kb ]; then
    log_message "Expected $x/size_kb to exist with nonzero size."
    exit 1;
  fi
  x_relative=$(echo $x | sed s:^$dir:: | sed s:^/::);
  echo php make_index.php $data_root $build $x_relative
  # note, $x_relative may be the empty string; this is valid.
  if ! php make_index.php $data_root $build "$x_relative" > $x/index.html; then
    log_message "Error making index.html in directory $x"
    exit 1;
  fi
done

log_message "Successfully created indexes in $dir"

dir_final=$data_root/build_index/$build

if [ -d $dir_final ]; then
  log_message "Removing existing data from $dir_final";
  if ! rm -r $dir_final; then
    log_message "Error removing existing data from $dir_final";
    exit 1;
  fi
fi

if mv $dir $dir_final; then
  log_message "Moved contents of $dir to $dir_final";
else
  log_message "Error moving contents of $dir to $dir_final";
  exit 1;
fi

exit 0;
