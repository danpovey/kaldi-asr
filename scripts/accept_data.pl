#!/usr/bin/perl

use Getopt::Long;
binmode(STDIN);

#my $submission_root = "/mnt/kaldi_asr_data/submitted";
my $submission_root = "/Users/danielpovey/temp_data";
my $block_size = 65536;   # affects memory usage, and how many hash marks are printed.

my $note;
my $branch;
my $name;
my $revision;
my $root;

$usage_message = "$0: usage: ssh uploads\@kaldi-asr.org accept_data.pl --revision <kaldi-svn-revision> --branch <branch-name> --name <your_name> --root <archive-root> < (your data)\n" .
   "  e.g.: cd egs/wsj\n" .
   "  tar cvz s5/{data,exp} | ssh uploads\@kaldi-asr.org accept_data.pl --revision 4131 --branch trunk --name Daniel_Povey --root egs/wsj\n";

if (@ARGV == 0) {
  print STDERR $usage_message;
  exit(1);
}

GetOptions ("branch=s" => \$branch,
            "revision=i" => \$revision,  # Kaldi revision number.
            "name=s" => \$name,
            "root=s" => \$root,
            "note=s" => \$note);

if (@ARGV > 0) {
  print STDERR $usage_message;
}


sub check_opt_generic {
  ($opt_name, $opt) = @_;
  if ($opt =~ /^\s+$/) { # The option is either empty or all spaces.
    print STDERR "The option --$opt_name is required\n";
    exit(1);
  }
  if ($opt =~ /[^[:ascii:]]/ || $opt =~ m:\n:) {
    print STDERR "Non-ASCII characters or newlines detected in option $opt_name: $opt\n";
    exit(1);
  }
}

check_opt_generic("note", $note);
check_opt_generic("branch", $branch);
check_opt_generic("name", $name);
check_opt_generic("root", $root);

if ($revision !~ m/^[\d]+$/) {
  print STDERR "$0: --revision <kaldi-svn-revision> option is required; invalid value '$revision'\n";
  exit(1);
}
print STDERR "$0: checking Kaldi that revision number $revision exists... ";

$cmd = "svn list -r$revision http://svn.code.sf.net/p/kaldi/code/ >/dev/null";

if (system($cmd) != 0) {
  print STDERR "$0: invalid Kaldi revision number $revision: command '$cmd' exited with status $?.\n";
  exit(1);
} else {
  print STDERR "[OK]\n";
}

if ($name !~ s/_/ /) {
  print STDERR "$0: expected your name to have underscores in it (these will be converted to spaces); got '$name' as --name option.\n";
  exit(1);
}

$branch =~ s:^/+::;  # Remove any leading slashes from branch.
$branch =~ s:/+$::;  # Remove any trailing slashes from branch.

if (! ($branch == "trunk" || $branch =~ m:^sandbox/: || $branch =~ m:^branches/:)
    || split("/", $branch) > 2) {
  print STDERR "$0: invalid value for --branch option, expected 'trunk' or 'sandbox/<foo>' or 'branches/<foo>', got '$branch'\n";
  exit(1);
}

print STDERR "$0: checking for valid branch... ";
$cmd = "svn list -r$revision http://svn.code.sf.net/p/kaldi/code/$branch/COPYING >/dev/null";
if (system($cmd) != 0) {
  print STDERR "$0: branch '$branch' does not seem to exist at Kaldi revision number $revision: command '$cmd' exited with status $?\n";
  exit(1);
} else {
  print STDERR "[OK]\n";
}

$root =~ s:^/+::;  # Remove any leading slashes from branch.
$root =~ s:/+$::;  # Remove any trailing slashes from branch.
if ($root !~ m:^egs:) {
  # If this is too restrictive, we can change it later.
  print STDERR "$0: expected root to start with 'egs' but it does not: value is '$root'\n";
  exit(1);
}

print STDERR "$0: checking for valid root... ";
$cmd = "svn list -r$revision http://svn.code.sf.net/p/kaldi/code/$branch/$root >/dev/null";
if (system($cmd) != 0) {
  print STDERR "$0: root directory '$root' in branch '$branch' does not seem to exist at Kaldi revision number $revision: command '$cmd' exited with status $?.  Please use a root location that exists in Kaldi, e.g. egs/wsj/s5, and make an archive relative to there\n";
  print STDERR $output;
  exit(1);
} else {
  print STDERR "[OK]\n";
}


# We'll first write this to a temporary directory, then move it to a suitable
# number when we're done.
$cmd = "mktemp -d $submission_root/tmp.XXXXX";
$tempdir = `$cmd`;
if ($? != 0 || $tempdir !~ m:^\S+$:) {
  die "failed to make temporary directory (server problem, maybe full disk)\n";
}
chop $tempdir;

print STDERR "$0: writing metadata to $tempdir... ";
if (!open(F, ">$tempdir/metadata")) {
  die "failed to open $tempdir/metadata\n";
}
print F "note=$note\n";
print F "branch=$branch\n";
print F "name=$name\n";
print F "root=$root\n";
print F "revision=$revision\n";
$time = time();  # UNIX time of submission, an integer.
print F "time=$time\n";
if (!close(F)) {
  die "failed to close metadata file $tempdir/metadata";
}
print STDERR "[OK]\n";

print STDERR "$0: writing archive data";

if (!open(A, ">$tempdir/archive.tar.gz")) {
  die "failed to open $tempdir/archive.tar.gz";
}
binmode(A);

$tot_written = 0;
while ( ($bytes = read(STDIN, $data, $block_size)) ) {
  if (! (print A $data)) { # note: in Perl, write is not the opposite of read;
                           # we just need to use print.
    die "$0: error writing data to $tempdir/archive.tar.gz after writing $tot_written bytes.";
  }
  $tot_written += $bytes;
  print STDERR ".";
}
if (!defined $bytes) {
  # When input is done, $bytes should be zero, not undefined.
  die "$0: error reading data from stdin, errno was $!";
}
if (!close(A)) {
  die "failed to close $tempdir/archive.tar.gz [disk full?]";
}

print STDERR "[OK, wrote $tot_written bytes]\n";

print STDERR "$0: checking archive.\n";

$cmd = "tar -tzf $tempdir/archive.tar.gz|";
if (!open(F, $cmd)) {
  die "error running command $cmd";
}
# We'll look at the common prefix of all things listed in the archive;
# this will help us detect problems with the root directory the user
# specified.
$common_prefix = <F>;
if (!defined $common_prefix) { # F was empty.
  die "$0: unable to list contents of archive.\n";
}
while (<F>) {
  if (length($_) > length($common_prefix)) {
    $_ = substr($_, 0, length($common_prefix));
  }
  if (length($common_prefix) > length($_)) {
    $common_prefix = substr($common_prefix, 0, length($_));
  }
  ($_ ^ $common_prefix) =~ /^(\0*)/;
  $common_prefix = substr($common_prefix, 0, length($1));
}
print STDERR "$0: common prefix of uploaded files in archive was '$common_prefix'\n";
print STDERR "$0: your files will be located at $branch/$root/$common_prefix; if this does not look right, let me know.\n";
if (!close(F)) {
  die "$0: error closing command $cmd, failed with status $?";
}
if ($common_prefix =~ m:^/:) { 
  # common_prefix starts with a /, meaning archive had absolute pathnames.
  die "$0: error in your archive, it has absolute pathnames.";
}
$common_prefix =~ s:[^/]$::g;  # Remove any trailing characters that are not "/".
                              # These could exist if there were directories or
                              # files that started with the same letter.
$common_prefix =~ s:/$::; # remove any trailing slash from the directory name.

print STDERR "$0: [info], common prefix of uploaded files in archive normalized to '$common_prefix'\n";

{ # We're checking that the user has not put the same thing in their "$branch/$root" and their
  # common_prefix, for example if "$branch/$root" = "/trunk/egs/wsj/s5" and
  # $common_prefix = "wsj/s5/data", then a prefix common_prefix is a suffix of
  # $branch/$root and we don't allow this as it likely means the user has made a mistake.
  @A = split("/", $common_prefix);
  @B = split("/", "$branch/$root");
  $len_a = @A;
  $len_b = @B;
  for ($len = 1; $len <= $len_a && $len <= $len_b; $len++) {
    $a_prefix = join("/", @A[0 .. ($len-1)]);
    $b_suffix = join("/", @B[($len_b-$len) .. ($len_b-1)]);
    if ($a_prefix eq $b_suffix) {
      print STDERR "$0: your archive seems to be relative to the wrong location; the prefix $a_prefix is a suffix of $branch/$root\n";
      exit(1);
    }
  }
}

# Creating this file lets me know that I haven't processed it yet.
$cmd = "touch $tempdir/QUEUED";
if (system($cmd) != 0) {
  die "failed to create QUEUED file";
}

# We'll make a directory like $root/11-- we'll take the highest numbered
# subdirectory of that directory, and add one to it. 

my $output = `ls $submission_root`;
if ($? != 0) {
  print STDERR "$0: failed to list directory $root on the server (server probem?)\n";
  exit(1);
}
$max = 0;
foreach $n (split(" ", $output)) {
  if ($n =~ m/^\d+$/ && $n > $max) { $max = $n; }
}
$build = $max + 1;
print STDERR "$0: assigning build number $build\n";


if (system("mv $tempdir $submission_root/$build") != 0) {
  die "$0: error moving $tempdir to $submission_root/$build\n";
}

print "$0: succeeded uploading build number $build.  Please ask dpovey\@gmail.com to rebuild the site.\n";
exit(0);

