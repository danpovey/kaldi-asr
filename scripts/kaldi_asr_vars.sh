
function log_message {
  echo "$0: $*" 1>&2
  echo "$0: $*" | logger -t kaldi-asr
}

data_root=/mnt/web-data/kaldi-asr-data
script_root=/var/www/kaldi-asr/scripts

# this affects all the shell scripts, but if you change this you also need to change
# accept_data.pl and remove_data.pl.
