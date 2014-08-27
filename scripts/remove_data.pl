#!/usr/bin/perl

use Getopt::Long;

#my $submission_root = "/mnt/kaldi-asr-data/submitted";
my $submission_root = "/Users/danielpovey/kaldi-asr/data/submitted";

my $name;

$usage_message = "$0: usage: ssh uploads\@kaldi-asr.org remove_data.pl --user \\\"<your name>\\\" <build-number>\n" .
  " note, the quotes do need to be escaped; it relates to the way ssh works.\n";

if (@ARGV == 0) {
  print STDERR $usage_message;
  exit(1);
}

GetOptions ("name=s" => \$name);

if (@ARGV != 1) {
  print STDERR $usage_message;
}

$build = $ARGV[0];

sub check_opt_generic {
  ($opt_name, $opt) = @_;
  if ($opt =~ /^\s*$/) { # The option is either empty or all spaces.
    print STDERR "The option --$opt_name is required\n";
    exit(1);
  }
  if ($opt =~ /[^[:ascii:]]/ || $opt =~ m:\n:) {
    print STDERR "Non-ASCII characters or newlines detected in option $opt_name: $opt\n";
    exit(1);
  }
}

if ($build !~ m/^[\d]+$/) {
  print STDERR "$0: invalid build number $build\n";
  exit(1);
}

check_opt_generic("name", $name);

$metadata = "$submission_root/$build/metadata";
$queued = "$submission_root/$build/QUEUED";

if (! -f $metadata) {
  printn STDERR "$0: error removing data: metadata file $metadata does not exist.\n";
  exit(1);
}
if (! -s $queued) {
  print STDERR "$0: file $queued is not nonempty.  Maybe the site is already being rebuilt.\n";
  print STDERR "   Ask dpovey\@gmail.com about removing it.\n";
  exit(1);
}


if (!open(M, "<$metadata")) {
  # we use die for the errors we don't really expect to ever happen; it's easier to type.
  die "Error opening metadata file $metadata";
}
while(<M>) {
  if (m/^name=(.+)/) {
    $name_from_metadata = $1;
  }
}
if (!defined $name_from_metadata) {
  die "Could not get name from metadata file $metadata";
}
if ($name_from_metadata != $name) {
  print STDERR "$0: Not removing submission since the name you specified '$name' does not match name in metadata file '$name_from_metadata'.\n";
  exit(1);
}
if (unlink ($queued) != 1) {
  print STDERR "$0: Error removing file $queued\n";
}

$cmd = "mv $submission_root/$build $submission_root/$build.to_delete";
if (system($cmd) != 0) {
  print STDERR "$0: error executing command '$cmd'\n";
  exit(1);
}

$cmd = "rm -r $submission_root/$build.to_delete";
if (system($cmd) != 0) {
  print STDERR "$0: error executing command '$cmd'\n";
  exit(1);
}

print STDERR "$0: successfully removed your submission number $build\n";

exit(0);
