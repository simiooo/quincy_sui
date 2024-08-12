import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart'
    hide Tooltip, Colors, FilledButton, showDialog;
import 'package:path_provider/path_provider.dart';
import 'package:quincy_sui/utils/quincy.dart';
import 'package:quincy_sui/utils/wiretConfi.dart';
import 'package:quincy_sui/widgets/config_menu.dart';
import 'package:toml/toml.dart';
import 'package:window_manager/window_manager.dart';

Directory? confDir;

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Directory appDocumentsDir;

  Map<String, Quincy>? quincyRuntime = {};

  List<Map<String, dynamic>> configDocList = [];

  getConfigList() async {
    appDocumentsDir = await getApplicationDocumentsDirectory();
    try {
      confDir = Directory(
          '${appDocumentsDir.path}${Platform.pathSeparator}quincy_conf_dir');
      if (confDir == null) {
        return;
      }
      var hasDir = await confDir!.exists();
      if (!hasDir) {
        await confDir!.create();
      }
      RegExp isConf = RegExp(r'\.toml$');
      var fileList = confDir!.list().takeWhile((f) {
        return isConf.firstMatch(f.path)?[0] != null;
      });
      configDocList = [];
      await for (final f in fileList) {
        try {
          var document = await TomlDocument.load(f.path);
          configDocList.add({"path": f.path, "doc": document});
        } catch (e) {
          print(e.toString());
        }
      }
      setState(() {});
    } catch (e) {
      final result = await showDialog<String>(
        context: context,
        builder: (context) => ContentDialog(
          title: const Text('Error'),
          content: Text(
            e.toString(),
          ),
          actions: [
            FilledButton(
              child: const Text('Confirm'),
              onPressed: () => Navigator.pop(context, 'User canceled dialog'),
            ),
          ],
        ),
      );
      print(e.toString());
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (mounted != true) {
      return;
    }
    getConfigList();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          // decoration: BoxDecoration(color: Colors.white),
          width: MediaQuery.sizeOf(context).width,
          height: MediaQuery.sizeOf(context).height,
          child: Column(
            children: [
              Expanded(
                  child: ConfigMenu(
                onDelete: (String path) async {
                  try {
                    if (quincyRuntime?[path] != null) {
                      quincyRuntime?[path]?.stop();
                      quincyRuntime?.remove(path);
                    }
                    await File(path).delete();
                    await getConfigList();
                  } catch (e) {
                    print(e);
                  }
                },
                confDir: confDir,
                confList: configDocList,
                quincyRuntime: quincyRuntime,
                onConnect: (doc, path) {
                  String? key = path;
                  if (key == null) {
                    return;
                  }
                  if (quincyRuntime?[key] == null) {
                    quincyRuntime![key] = Quincy(configPath: path)
                      ..onStatusChanged((status) {
                        setState(() {});
                      })
                      ..onLogChanged((logs, errorLogs) {
                        setState(() {});
                      });
                  } else {
                    quincyRuntime![key]!.restart();
                  }
                },
                onUpdated: () {
                  getConfigList();
                },
                onChanged: (doc) async {
                  if (confDir == null) {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return ContentDialog(
                            title: const Text('Error'),
                            content: Text(
                              'Configuration directory not found.',
                            ),
                            actions: [
                              FilledButton(
                                child: const Text('Confirm'),
                                onPressed: () => Navigator.pop(
                                    context, 'User canceled dialog'),
                              ),
                            ],
                          );
                        });
                    return;
                  }
                  var content = doc.toString();
                  await writeConf(content, confDir);
                  getConfigList();
                },
              ))
            ],
          ),
        ),
        Positioned(
            top: 0,
            left: 0,
            height: MediaQuery.sizeOf(context).height,
            width: 5,
            child: MouseRegion(
              cursor: SystemMouseCursors.resizeColumn,
              child: GestureDetector(
                onTapDown: (detail) {
                  windowManager.startResizing(ResizeEdge.left);
                },
              ),
            )),
        Positioned(
            top: 0,
            right: 0,
            height: MediaQuery.sizeOf(context).height,
            width: 5,
            child: MouseRegion(
              cursor: SystemMouseCursors.resizeColumn,
              child: GestureDetector(
                onTapDown: (detail) {
                  windowManager.startResizing(ResizeEdge.right);
                },
              ),
            )),
        Positioned(
            bottom: 0,
            right: 0,
            height: 5,
            width: MediaQuery.sizeOf(context).width,
            child: MouseRegion(
              cursor: SystemMouseCursors.resizeRow,
              child: GestureDetector(
                onTapDown: (detail) {
                  windowManager.startResizing(ResizeEdge.bottom);
                },
              ),
            )),
        Positioned(
            top: 0,
            right: 0,
            height: 15,
            width: MediaQuery.sizeOf(context).width,
            child: Column(
              children: [
                Container(
                  height: 15,
                  width: MediaQuery.sizeOf(context).width,
                  child: GestureDetector(
                    onTapDown: (details) {
                      windowManager.startDragging();
                    },
                  ),
                )
              ],
            )),
      ],
    );
  }
}
