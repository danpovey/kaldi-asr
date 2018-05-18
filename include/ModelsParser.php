<?php

class ModelsParser {

  public static function parseInfoFile($path) {
    if (file_exists($path)) {
      $contents = file_get_contents($path);
      $contentParts = explode("\n", $contents);
      $info = [];
      foreach ($contentParts as $part) {
        if ($part === "") {
          continue;
        }
        if (substr($part, 0, 5) === 'name:') {
          $info['name'] = substr($part, 5);
        } else if (substr($part, 0, 9) === 'category:') {
          $info['category'] = substr($part, 9);
        } else if (substr($part, 0, 18) === 'short_description:') {
          $info['short_description'] = substr($part, 18);
        } else if (substr($part, 0, 17) === 'long_description:') {
          $info['long_description'] = substr($part, 17);
        } else {
          return ['error' => "Your info.txt file is not formatted correctly."];
        }
      }
      return $info;
    } else {
      return ['error' => "The file $path does not exist."];
    }
  }

  public static function parseModelsFile($path) {
    if (file_exists($path)) {
      $contents = file_get_contents($path);
      $contentParts = explode("\n\n", trim($contents));
      $models = [];

      foreach ($contentParts as $key => $model) {
        if ($model === "") {
          continue;
        }
        $modelParts = explode("\n", $model);
        foreach ($modelParts as $part) {
          if ($part === "") {
            continue;
          }
          if (substr($part, 0, 11) === 'model_name:') {
            $models[$key]['model_name'] = substr($part, 11);
          } else if (substr($part, 0, 9) === 'filename:') {
            $models[$key]['filename'] = substr($part, 9);
          } else if (substr($part, 0, 5) === 'date:') {
            $models[$key]['date'] = substr($part, 5);
          } else if (substr($part, 0, 14) === 'uploader_name:') {
            $models[$key]['uploader_name'] = substr($part, 14);
          } else if (substr($part, 0, 15) === 'uploader_email:') {
            $models[$key]['uploader_email'] = substr($part, 15);
          } else if (substr($part, 0, 14) === 'kaldi_version:') {
            $models[$key]['kaldi_version'] = substr($part, 14);
          } else if (substr($part, 0, 18) === 'kaldi_version_url:') {
            $models[$key]['kaldi_version_url'] = substr($part, 18);
          } else if (substr($part, 0, 12) === 'recipe_name:') {
            $models[$key]['recipe_name'] = substr($part, 12);
          } else if (substr($part, 0, 11) === 'recipe_url:') {
            $models[$key]['recipe_url'] = substr($part, 11);
          } else if (substr($part, 0, 11) === 'model_type:') {
            $models[$key]['model_type'] = substr($part, 11);
          } else if (substr($part, 0, 11) === 'error_rate:') {
            $models[$key]['error_rate'] = substr($part, 11);
          } else if (substr($part, 0, 6) === 'notes:') {
            $models[$key]['notes'] = substr($part, 6);
          } else {
            return ['error' => "Your models.txt file is not formatted correctly."];
          }
        }
      }
      return $models;
    } else {
      return ['error' => "The file $path does not exist."];
    }
  }

}
