<?php

class ModelsTableRow {
  private static $row = <<<EOT
    <tr>
        <td>M%s</td>
        <td><a href="/models/m%s">%s</a></td>
        <td>%s</td>
        <td>%s</td>
    </tr>
EOT;
  public static function printRow($id, $name = '', $category = '', $short_description = '') {
    $row = self::$row;
    echo sprintf("$row", $id, $id, $name, $category, $short_description);
  }
}
