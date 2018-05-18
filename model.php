<?php
require("./include/ModelsParser.php");
require("./include/ModelsCard.php");
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

      <div id="mainContent">

      <?php
      if (isset($_GET['id']) && is_numeric($_GET['id']) && preg_match("/^[1-9][0-9]{0,15}$/", $_GET['id'])) {
        $id = $_GET['id'];
        $directory = dirname(__FILE__) . "/models/$id";
        if (file_exists($directory) && is_dir($directory)) {
          if (file_exists("$directory/info.txt") && file_exists("$directory/models.txt")) {
            $info = ModelsParser::parseInfoFile("$directory/info.txt");
            echo '<h1>'.$info['name'].'</h1>';
            echo '<p>'.$info['long_description'].'</p>';
            $models = ModelsParser::parseModelsFile("$directory/models.txt");
            foreach ($models as $model) {
              $model['id'] = $id;
              ModelsCard::printModel($model);
            }
          } else {
            echo 'No models available.';
          }
        }
      } else {
        echo 'Badly formatted url';
      }
      ?>
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
