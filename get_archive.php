<?php
// When a user asks for a file such as
//  /downloads/build/10/trunk/egs/wsj/s5/archive.tar.gz
// this will be converted by our our apache config (see the file config/kaldi-asr)
// into something of the form
//  get_archive.php?id=10/trunk/egs/wsj/s5

$id = $_GET["id"]; // e.g. 10/trunk/egs/wsj/s5
if (!defined $id) {
   syslog(LOG_WARN, "get_archive.php called without the ?id=XXX option");
   print "<html> <body> Error getting archive, expected the ?id=XXX option to be given.  </body> </html>\n";
   http_response_code(404);
   exit(0);
}
if (preg_match('#^[0-9]+/#', $id) != 1) {
   syslog(LOG_WARN, "get_archive.php called with invalid id option: id=$id");
   print "<html> <body> Error getting archive, invalid id option id=$id  </body> </html>\n";
   http_response_code(404);
   exit(0);
}

$id_norm = htmlspecialchars($id);
$doc_root = $_SERVER["DOCUMENT_ROOT"];
if (!defined $doc_root) { 
   print "<html> <body> Error getting document root  </body> </html>\n";
   http_response_code(501);
   exit(0);
}
// We are assuming that $doc_root/downloads is a symlink to the disk
// (e.g. /mnt/kaldi-asr-data).  We do it like this so that we don't
// require this script to be told what the data root (e.g. /mnt/kaldi-asr-data)
// os.
$index_location = "$doc_root/downloads/build_index/$id_norm";
$build_location = "$doc_root/downloads/build/$id_norm";


// Check that we have enough server space to fulfil this request.
$file_contents = file("$index_location/size_kb");
if ($file_contents === false || count($file_contents) != 1
    || ! preg_match('/^\d+$/', $file_contents[0])) {
  syslog(LOG_ERR, "get_archive.php: error getting size of data from $index_location/size_kb");
  print "<html> <body> Error getting archive, invalid location, id=$id  </body> </html>\n";    
  http_response_code(404);
  exit(0);
}
$size_kb = $file_contents[0];


// We need to confirm that we have enough free space to do what we want to do.
// Note: the user can let $doc_root/downloads/tmp/ be a separate volume
// from our normal data root, perhaps one co-located

$free_space_bytes = disk_total_space("$doc_root/downloads/tmp/");
if ($free_space_bytes === false) {
  syslog(LOG_ERR, "get_archive.php: error getting free space on server");
  print "<html> <body> Server error (error finding amount of free space)  </body> </html>\n";    
  http_response_code(502);
  exit(0);
}

// we don't know how many server processes are running at once.  We should develop
// a better mechanism for this, and also consider caching some of the the most recenly
// created archives.
$safety_factor = 3;
if (! ($size_kb * 1000.0 * $safety_factor) < $free_space_bytes) {

    $fp = fopen( $filename,"w"); // open it for WRITING ("w")
    if (flock($fp, LOCK_EX)) {
        // do your file writes here
        flock($fp, LOCK_UN); // unlock the file

            if (flock($fp, LOCK_EX)) {


?>
