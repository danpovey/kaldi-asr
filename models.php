<?php
require("./include/ModelsParser.php");
require("./include/ModelsTableRow.php");
?>

<!DOCTYPE html>
<html>

<head>
  <meta name="description" content="Kaldi ASR"/>
  <meta charset="UTF-8">
  <link rel="icon" type="image/png" href="/kaldi_ico.png"/>
  <link rel="stylesheet" type="text/css" href="/style.css"/>
  <title>Kaldi ASR</title>
</head>

<body>
  <div class="container">
    <div id="centeredContainer">

      <div id="headerBar">
        <div id="headerLeft">
          <a href="http://kaldi-asr.org">
            <img id="logoImage" src="/kaldi_text_and_logo.png">
          </a>
        </div>
        <div id="headerRight">
          <img id="logoImage" src="/kaldi_logo.png">
        </div>
      </div>

      <hr>

      <div id="topBar">
        <a class="topButtons" href="/index.html">Home</a>
        <a class="topButtons" href="/doc/">Documentation</a>
        <a class="topButtons" href="/forums.html">Help!</a>
        <a class="topButtons" href="/models.html">Models</a>
      </div>

      <hr>

      <div id="rightCol">
        <div class = "contact_info">
          <div class="contactTitle">Contact</div>
          <a href=mailto:dpovey@gmail.com> dpovey@gmail.com </a>  <br/>
          Phone: 425 247 4129  <br/>
          (Daniel Povey) <br/>
        </div>
      </div>

      <div id="modelList">

        <h1>Models</h1>
        <p class="model-intro">This page contains Kaldi models available for download as .tar.gz archives. They may be downloaded and used for any purpose. Older models can be found on the <a href="/downloads/all">downloads page</a>. If you have models you would like to share on this page please <a href="mailto:dpovey@gmail.com">contact us</a>.</p>

	<table>
          <tr>
            <th>Resource</th>
            <th>Name</th>
            <th>Category</th>
            <th>Summary</th>
          </tr>
        <?php
          $root = dirname(__FILE__) . "/models/";
          $dirs = new DirectoryIterator($root);
          $sortedDirs = [];
          foreach ($dirs as $dir) {
            if (!$dir->isDot() && $dir->isDir() && is_numeric($dir->getFilename()) && preg_match("/^[1-9][0-9]{0,15}$/", $dir->getFilename())) {
              $sortedDirs[$dir->getFilename()] = NULL;
            }
          }
          ksort($sortedDirs);
          foreach($sortedDirs as $key => $dir) {
            $directoryId = $key;
            $modelInfo = ModelsParser::parseInfoFile(dirname(__FILE__) . "/models/$directoryId/info.txt");
            if (!empty($modelInfo) && !isset($modelInfo['error'])) {
              ModelsTableRow::printRow($directoryId, $modelInfo['name'], $modelInfo['category'], $modelInfo['short_description']);
            }
          }
        ?>
        </table>
      </div>
      <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js"></script>

      <div style="clear: both"></div>

      <div id="footer">
        <p>
          <a href="http://jigsaw.w3.org/css-validator/check/referer">
            <img style="border:0;width:88px;height:31px"
            src="http://jigsaw.w3.org/css-validator/images/vcss-blue"
            alt="Valid CSS!" />
          </a>
        </p>
      </div>

    </div>
  </div>
</body>
</html>
