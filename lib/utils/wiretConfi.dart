import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:quincy_sui/widgets/home.dart';

Future<File?>? writeConf(String content, Directory? localConfDir) async {
  localConfDir ??= confDir;
  var name = sha1.convert(utf8.encode(content));
  var file = File(
      "${localConfDir!.path}${Platform.pathSeparator}quincy_conf_$name.toml");
  return await file.writeAsString(content);
}
