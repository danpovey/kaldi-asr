<?php
/** 
  * This script is for easily deploying updates to Github repos to your local server. It will automatically git clone or 
  * git pull in your repo directory every time an update is pushed to your $BRANCH (configured below).
  * 
  * Read more about how to use this script at http://behindcompanies.com/2014/01/a-simple-script-for-deploying-code-with-githubs-webhooks/
  * 
  * INSTRUCTIONS:
  * 1. Edit the variables below
  * 2. Upload this script to your server somewhere it can be publicly accessed
  * 3. Make sure the apache user owns this script (e.g., sudo chown www-data:www-data webhook.php)
  * 4. (optional) If the repo already exists on the server, make sure the same apache user from step 3 also owns that 
  *    directory (i.e., sudo chown -R www-data:www-data)
  * 5. Go into your Github Repo > Settings > Service Hooks > WebHook URLs and add the public URL 
  *    (e.g., http://example.com/webhook.php)
  *
**/
// Set Variables
$LOCAL_ROOT         = "/mnt/kaldi-repos/";
$LOCAL_REPO_NAME    = "kaldi-git";
$LOCAL_REPO         = "{$LOCAL_ROOT}/{$LOCAL_REPO_NAME}";
$REMOTE_REPO        = "https://github.com/kaldi-asr/kaldi.git";
$BRANCH             = "master";

// I had to change this from _POST['payload'] to  $_SERVER['HTTP_X_GITHUB_EVENT']
// to make it work -- yenda
if ( $_SERVER['HTTP_X_GITHUB_EVENT'] == 'push' ) {
  // Only respond to POST requests from Github
  
  if( file_exists($LOCAL_REPO) ) {
    
    // If there is already a repo, just run a git pull to grab the latest changes
    $return = shell_exec("cd {$LOCAL_REPO} && git pull");
    header("Content-Type: text/plain");
    http_response_code(200);
    print($return);
  } else {
    
    // If the repo does not exist, then clone it into the parent directory
    shell_exec("cd {$LOCAL_ROOT} && git clone {$REMOTE_REPO}");
    
    header("Content-Type: text/plain");
    http_response_code(200);
  }
} elseif (array_key_exists ('HTTP_X_GITHUB_EVENT', $_SERVER) ) {
  header("Content-Type: text/plain");
  http_response_code(202);
} else {
  http_response_code(521);
  $output_including_status = shell_exec("cd {$LOCAL_REPO} && git status; git remote show origin; echo Exit status: $?");
  header("Content-Type: text/plain");
  print($output_including_status);
  die("done " . mktime());
}
?>

