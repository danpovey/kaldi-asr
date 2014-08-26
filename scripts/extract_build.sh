#!/bin/bash

if ! . kaldi_asr_vars.sh; then
  echo "Failed to source kaldi_asr_vars.sh" 1>&2
  exit 1;
fi

if [ $# -ne 1 ] || ! [ "$1" -gt 0 ]; then
  echo "Usage: $0 <build-number>"
  echo "e.g.: $0 15"
  echo "This script will extract the data in $data_root/submitted/<build-number> into $data_root/build/<build-number>"
  echo "with output in $data_root/build/<build-number>"
  exit 1;
fi

build=$1


# First extract the data into a temporary directory.

submitted=$data_root/submitted/$build
tmpdir=$data_root/build/$build.temp
destdir=$data_root/build/$build

if [ -d $tmpdir ]; then
  log_message "removing old copy of temporary directory $tmpdir (perhaps a broken run?)";
  rm -r $tmpdir || exit 1;
fi

if ! mkdir $tmpdir; then
  log_message "error creating temporary directory $tmpdir"
  exit 1;
fi


if [ ! -f $submitted/metadata ]; then
  log_message "No such file $submitted/metadata"
  exit 1;
fi

if [ ! -f $submitted/archive.tar.gz ]; then
  log_message "No such file $submitted/archive.tar.gz"
  exit 1;
fi


# source a command like 'branch=trunk', so we set the variable.
eval `grep '^branch=' $submitted/metadata`;

# source a command like 'root=egs/wsj', so we set the variable.
eval `grep '^root=' $submitted/metadata`;

extraction_root=$tmpdir/$branch/$root/
if ! mkdir -p $extraction_root; then
  log_message "failed to create directory $extraction_root"
  exit 1;
fi

excludes=()  # options to tar that direct various things to be excluded from the extraction.
excludes+=('--exclude=._*')  # files with metadata that get created on a Mac.
excludes+=('--exclude=*~') # emacs backup
excludes+=('--exclude=#*#') # emacs autosave
excludes+=('--exclude=.DS_Store') # something from Macs.
excludes+=('--exclude=.backup') # Kaldi creates these when doing various operations in data/.
excludes+=('--exclude=.trash') # Sometimes I use this directory name when I want to get rid of stuff.
excludes+=('--exclude=.svn') # In most cases we won't want to store .svn directories in these uploads.
# The things excluded by the next pattern are subdirectories of things like
# data/train/, that get created by the script split_data_dir.sh.  They are
# derived data, so I don't want to keep them around.  I'm not 100% sure whether
# deleting them is a good idea.
excludes+=('--exclude=split[0-9]' '--exclude=split[0-9][0-9]' '--exclude=split[0-9][0-9][0-9]') 
excludes+=('--exclude=* *') # exclude filenames with spaces in them.

# We may at some later point have to mess with these exclusion options.
if ! tar -v -C $extraction_root -xf $submitted/archive.tar.gz "${excludes[@]}"; then
  log_message "failed to extract data."
  exit 1;
fi

log_message "successfully extracted data to $extraction_root"

if [ -d $destdir ]; then
  log_message "removing old copy of processed data, in $destdir"
  if ! rm -r $destdir; then
    log_message "error removing old data directory $destdir"
    exit 1;
  fi
fi

if ! mv $tmpdir $destdir; then
  log_message "error moving directory $tmpdir to $destdir"
  exit 1;
fi

if [ -s $submitted/QUEUED ]; then
  log_message "removing contents of file $submitted/QUEUED";
  if ! echo -n > $submitted/QUEUED; then
    log_message "Error removing contents of file $submitted/QUEUED";
    exit 1;
  fi
fi

exit 0;
