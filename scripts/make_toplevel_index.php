<?php
// Called from ./make_toplevel_index_recursive.sh.
// Usage: php make_toplevel_index.php <root-dir> <relative-path> <list-of-branches>
//    e.g.: php make_toplevel_index.php /mnt/kaldi-asr-data egs/wsj trunk sandbox/online
  date_default_timezone_set('US/Eastern');
  $date = date('D, d M Y H:i:s');
  print "<!-- Generated by $argv[0] at $date -->\n";
?>
<!DOCTYPE html>
<html>
  <head>
    <meta name="description" content="Kaldi ASR"/>
    <meta charset="UTF-8">
    <link rel="icon" type="image/png" href="/kaldi_ico.png"/>
    <link rel="stylesheet" type="text/css" href="/indexes.css"/> 
    <title>Kaldi ASR</title>

<?php
if (count($argv) < 4) {
   // note: first argument is make_toplevel_index.php, we need at least 3 real arguments
   syslog(LOG_ERR, "make_toplevel_index.php called with too few arguments: " .
         implode(" ", $argv));
  exit(1);
}
$root = $argv[1];
$relative_path = $argv[2];  // Caution: this may be the empty string.

$slash_relative_path = ($relative_path != '' ? "/$relative_path" : '');

$destdir = "$root/all.temp$slash_relative_path";

$branches = array();
for ($n = 3; $n < count($argv); $n++) {
  $branch = $argv[$n];
  if ($branch == "trunk") {
    array_unshift($branches, $branch);  // Make sure 'trunk' goes first.
  } else {
    $branches[] = $branch;  // append to branches array.
  }
}


// we'll index the associative array "all_metadata" as
// <branch-index>|<variable-name>, e.g. "sandbox/online.size_human_readable" = 20K
// this should be safe (no conflicts) because the variable names will never contain a dot.
$all_metadata = array();  

foreach ($branches as $branch) {
  $metadata = "$root/tree/$branch$slash_relative_path/build_metadata";
  $metadata_array = file($metadata); // returns file as array, or false on error.
  if ($metadata_array == false || count($metadata_array) < 3) {
    syslog(LOG_ERR, "make_toplevel_index.php: file $metadata is too small or couldn't be opened.");
    exit(1);
  }
  foreach ($metadata_array as $line) {
    if (preg_match('/^([a-zA-Z0-9_]+)=(.+)/', $line, $matches) != 1 || count($matches) != 3) {
      # we'll allow empty lines in metadata file.
      if (preg_match('/^\s*$/', $line) != 1) {
        syslog(LOG_ERR, "make_toplevel_index.php: bad line in file $metadata: $line");
        exit(1);
      }
    }
    $var_name = $matches[1];
    $var_value = $matches[2];
    $all_metadata["$branch.$var_name"] = $var_value;
  }
  foreach (array('num_builds', 'most_recent_build', 'uploader_name', 'size_human_readable', 'date') as $var_name) {
    if (!isset($all_metadata["$branch.$var_name"])) {
      syslog(LOG_ERR, "make_toplevel_index.php: variable $var_name not set in metadata file $metadata");
      exit(1);
    }
  }
  $most_recent_build_index = $all_metadata["$branch.most_recent_build"];
  $all_metadata["$branch.branch_index_url"] = "/downloads/tree/$branch$slash_relative_path";
  $all_metadata["$branch.most_recent_build_index_url"] = "/downloads/build/$most_recent_build_index/$branch$slash_relative_path";
}

// Now figure out the URL $my_url by which we can refer to the index.html that we're
// creating in this script.
$my_url = "/downloads/all$slash_relative_path";



// get a list of subdirectories of this directory.
// $subdirs will be indexed by all strings $subdir, such that
// /downloads/tree/$branch/$relative_path/$subdir exists and is a directory for at least
// one member $branch of $branches.
// We'll use this list to make links in our
// output html that go to subdirectories of $my_url.  
// note: the entries will appear as the key of $subdirs,
// not the value.  The entry will always be 1.

$subdirs = array();

foreach ($branches as $branch) {
  $branch_dir = "$root/tree/$branch$slash_relative_path";
  $entries = scandir($branch_dir); // returns array of entries.  
  foreach ($entries as $entry) {
    $path = "$branch_dir/$entry";
    if (is_dir($path) && !is_link($path) && $entry != "." && $entry != "..") {
      $subdirs[$entry] = 1;
    }
  }
}

ksort($subdirs, SORT_STRING); // sort low to high on key [string]


?>

    
  </head>
  <body>
    <div class="container">
      <div id="centeredContainer">
        <div id="headerBar">
         <div id="headerLeft">  <a href="http://kaldi-asr.org"><image id="logoImage" src="/kaldi_text_and_logo.png"></a> </div>
         <div id="headerRight"> <image id="logoImage" src="/kaldi_logo.png">  </div>
        </div>
        <hr>
        <div id="topBar">
          <a class="topButtons" href="/index.html">Home</a>
          <a class="topButtons" href="/doc/">Documentation</a>
          <a class="topButtons" href="/forums.html">Help!</a>
          <a class="myTopButton" href="/downloads/all">Downloads</a>
          <a class="topButtons" href="/uploads.html">Uploading your builds</a>
        </div>
        <hr>


        <div id="mainContent">

        <h3>
         <?php print "Index of /$relative_path"; ?>
        </h3>


        <h3> Branches available for this directory: </h3>

       <table style="margin-top:0.2em">
        <tr>  <th>Branch</th> <th>Number of builds</th> <th>Most recent build</th> <th>Date</th> <th>Uploader</th> <th>Size</th> </tr>
  <?php
       foreach ($branches as $branch) {
         foreach (array('num_builds', 'most_recent_build', 'uploader_name', 'size_human_readable', 'date',
                       'branch_index_url', 'most_recent_build_index_url') as $var_name) {
           if (! isset($all_metadata["$branch.$var_name"])) {
             syslog(LOG_ERR, "make_toplevel_index.php: variable $branch.$var_name not set in metadata");
             exit(1);
           }
           $$var_name = $all_metadata["$branch.$var_name"];
         }
         print "<tr> <td> <a href='$branch_index_url'>$branch</a> </td> ";
         print " <td> $num_builds </td> ";
         print " <td> <a href='$most_recent_build_index_url'> $most_recent_build </td> ";
         print " <td> $date </td> ";
         print " <td> $uploader_name </td> ";
         print " <td> $size_human_readable </td> </tr>\n";
       }
   ?>
    </table>    

     

      <h3> Subdirectories: </h3>
   <?php
      foreach ($subdirs as $subdir => $foo) {
         print "           <a href='$my_url/$subdir'> $subdir/ </a> <br>\n";
      }
      if ($relative_path != '') {
        print "           <p/>\n";
        print "           <a href='$my_url/..'> [parent directory] </a> <br>\n";
      }
   ?>
        <p>
       </div>  <!-- main content.  -->
      </div> 
    </div>
  </body>      
</html>

