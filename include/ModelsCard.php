<?php

class ModelsCard {

  public static function printModel($modelArray) {

    $dirId = $modelArray['id'];

    if (isset($modelArray['model_name'])) {
      $model_name = trim($modelArray['model_name']);
    } else {
      $model_name = '';
    }

    if (isset($modelArray['filename'])) {
      $filename = trim($modelArray['filename']);
    } else {
      $filename = '';
    }

    if (isset($modelArray['date'])) {
      $date = trim($modelArray['date']);
    } else {
      $date = '';
    }

    if (isset($modelArray['uploader_name'])) {
      $uploader_name = trim($modelArray['uploader_name']);
    } else {
      $uploader_name = '';
    }

    if (isset($modelArray['uploader_email'])) {
      $uploader_email = trim($modelArray['uploader_email']);
    } else {
      $uploader_email = '';
    }

    if (isset($modelArray['recipe_name'])) {
      $recipe_name = trim($modelArray['recipe_name']);
    } else {
      $recipe_name = '';
    }

    if (isset($modelArray['recipe_url'])) {
      $recipe_url = trim($modelArray['recipe_url']);
    } else {
      $recipe_url = '';
    }

    if (isset($modelArray['kaldi_version'])) {
      $kaldi_version = trim($modelArray['kaldi_version']);
    } else {
      $kaldi_version = '';
    }

    if (isset($modelArray['kaldi_version_url'])) {
      $kaldi_version_url = trim($modelArray['kaldi_version_url']);
    } else {
      $kaldi_version_url = '';
    }

    if (isset($modelArray['model_type'])) {
      $model_type = trim($modelArray['model_type']);
    } else {
      $model_type = '';
    }

    if (isset($modelArray['error_rate'])) {
      $error_rate = trim($modelArray['error_rate']);
    } else {
      $error_rate = '';
    }

    if (isset($modelArray['notes'])) {
      $notes = trim($modelArray['notes']);
    } else {
      $notes = '';
    }

    $model = '';
    $model .= '<div class="model">';
    $model .= "<h2>$model_name</h2>";

    $model .= '<div class="dl-bar">';
    $path = "models/$dirId/$filename";
    $model .= '<a href="/'.$path.'">';
    $model .= '<span class="dl-link">';
    $modelSize = self::get_file_size($path);
    $model .= 'Download <aside>'.$modelSize.'</aside>';
    $model .= '</span>';
    $model .= '</a>';
    $model .= '</div>';

    $model .= '<dl>';
    if (!empty($date)) {
      $model .= "<dt>Date</dt><dd>$date</dd>";
    }

    if (!empty($uploader_name)) {
      $model .= "<dt>Uploader</dt>";
      $model .= "<dd>";
      if (!empty($uploader_email)) {
        $model .= "<a target=\"_blank\" href=\"mailto:$uploader_email\">$uploader_name</a>";
      } else {
        $model .= $uploader_name;
      }
      $model .= "</dd>";
    }

    if (!empty($recipe_name)) {
      $model .= '<dt>Recipe</dt>';
      $model .= '<dd>';
      if (!empty($recipe_url)) {
        $model .= '<a target="_blank" href="'.$recipe_url.'">'.$recipe_name.'</a>';
      } else {
        $model .= $recipe_name;
      }
      $model .= '</dd>';
    }

    if (!empty($kaldi_version)) {
      $model .= '<dt>Kaldi Version</dt>';
      $model .= '<dd>';
      if (!empty($kaldi_version_url)) {
        $model .= '<a target="_blank" href="'.$kaldi_version_url.'">'.$kaldi_version.'</a>';
      } else {
        $model .= $kaldi_version;
      }
      $model .= '</dd>';
    }

    if (!empty($model_type)) {
      $model .= '<dt>Model Type</dt>';
      $model .= "<dd>$model_type</dd>";
    }

    if (!empty($error_rate)) {
      $model .= '<dt>Error Rate</dt>';
      $model .= "<dd>$error_rate</dd>";
    }

    if (!empty($notes)) {
      $model .= '<dt>Notes</dt>';
      $model .= '<dd><div class="note">';
      $model .= $notes;
      $model .= '</div></dd>';
    }

    $model .= '</dl>';
    $model .= '</div>';
    echo $model;
  }

  public static function get_file_size($path) {
    $size = trim(`stat -L -c '%s' $path`);
    if ($size === false || preg_match('/^[0-9]+$/', $size) != 1) {
      error_log("Error getting size of file $path, size is '$size'");
      return "error getting size";
    }
    $len = strlen($size);
    if ($len > 10) {
       return substr($size, 0, $len - 9) . "G";
    } elseif ($len == 10) {
       return $size[0] . "." . $size[1] . "G";
    } elseif ($len > 7) {
       return substr($size, 0, $len - 6) . "M";
    } elseif ($len == 7) {
       return $size[0] . "." . $size[1] . "M";
    } elseif ($len > 4) {
       return substr($size, 0, $len - 3) . "K";
    } elseif ($len == 4) {
       return $size[0] . "." . $size[1] . "K";
    } else {
       return $size . " bytes";
    }
  }
}
