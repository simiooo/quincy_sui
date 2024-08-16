import 'dart:io';

import 'package:path_provider/path_provider.dart';

class CommonPath {
  static Future<Directory> get confDir async {
    var appDocumentsDir = await getApplicationDocumentsDirectory();
    var confDir = Directory(
        '${appDocumentsDir.path}${Platform.pathSeparator}quincy_conf_dir');
    return confDir;
  }
}
