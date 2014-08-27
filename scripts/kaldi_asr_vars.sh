
function log_message {
  echo "$0: $*" 1>&2
  echo "$0: $*" | logger -t kaldi-asr
}

data_root=/mnt/kaldi-asr-data
script_root=/var/www/kaldi-asr/scripts

if [ $(hostname) == Daniels-MacBook-Air-2.local ]; then
  # using this for testing.
  data_root=/Users/danielpovey/kaldi-asr/data
  script_root=/Users/danielpovey/kaldi-asr/scripts
fi

# this affects all the shell scripts, but if you change this you also need to change
# accept_data.pl and remove_data.pl.
