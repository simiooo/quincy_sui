import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart'
    hide ButtonStyle, Colors, showDialog, Tooltip, IconButton;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quincy_sui/main.dart';
import 'package:quincy_sui/store/theme.dart';
import 'package:quincy_sui/utils/quincy.dart';
import 'package:quincy_sui/utils/wiretConfi.dart';
import 'package:quincy_sui/widgets/config_display.dart';
import 'package:quincy_sui/widgets/config_form.dart';
import 'package:quincy_sui/widgets/window_control.dart';
import 'package:super_clipboard/super_clipboard.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';
import 'package:toml/toml.dart';
import 'package:window_manager/window_manager.dart';

class ConfigMenu extends StatefulWidget {
  List<Map<String, dynamic>>? confList;
  Map<String, Quincy?>? quincyRuntime;
  Directory? confDir;
  void Function(String key)? onDelete;
  void Function()? onUpdated;
  void Function(TomlDocument doc, String path)? onConnect;
  void Function(TomlDocument doc)? onChanged;
  ConfigMenu(
      {Key? key,
      this.onUpdated,
      this.quincyRuntime,
      this.confList,
      this.onDelete,
      this.onChanged,
      required this.confDir,
      this.onConnect})
      : super(key: key);

  @override
  _ConfigMenuState createState() => _ConfigMenuState();
}

class _ConfigMenuState extends State<ConfigMenu> with WindowListener {
  int? topIndex;
  PaneDisplayMode displayMode = PaneDisplayMode.compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      // width: MediaQuery.sizeOf(context).width,
      // height: MediaQuery.sizeOf(context).height,
      child: DropRegion(
          formats: Formats.standardFormats,
          hitTestBehavior: HitTestBehavior.opaque,
          onDropOver: (event) {
            return DropOperation.copy;
          },
          onPerformDrop: (event) async {
            final items = event.session.items;
            for (var item in items) {
              if (item.dataReader == null) {
                return;
              }
              final reader = item.dataReader!;
              if (true) {
                
                reader.getFile(tomlFormat, (file) async {
                    var content = String.fromCharCodes(await file.readAll());
                    TomlDocument.parse(content);
                    await writeConf(content, null);
                    if(widget.onUpdated == null) {
                      return;
                    }
                    widget.onUpdated!();
                }, onError: (error) async {
                  await displayInfoBar(context, builder: (context, close) {
                    return InfoBar(
                      title: Text(context.tr('读取文件错误')),
                      content: Text(error.toString()),
                      action: IconButton(
                        icon: const Icon(FluentIcons.clear),
                        onPressed: close,
                      ),
                      severity: InfoBarSeverity.warning,
                    );
                  });
                });
              }
            }
          },
          child: NavigationView(
            appBar: NavigationAppBar(
                title: InkWell(
                  onTapDown: (detail) {
                    windowManager.startDragging();
                  },
                  child: Container(
                    width: MediaQuery.sizeOf(context).width,
                    child: Text(context.tr('Quincy Sui')),
                  ),
                ),
                leading: Container(child: Icon(FluentIcons.database)),
                actions: WindowControl()),
            pane: NavigationPane(
              footerItems: [
                PaneItem(
                  icon: const Icon(FluentIcons.settings),
                  title: Text(context.tr('Settings')),
                  body: Container(
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                    child: Text("Config path is in ${widget.confDir ?? "-"}"),
                  ),
                ),
                PaneItemAction(
                  icon: const Icon(FluentIcons.add),
                  title: Text(context.tr('Add New Item')),
                  onTap: () async {
                    final result = await showDialog<String>(
                        context: context,
                        builder: (context) =>
                            ConfigForm(onChanged: widget.onChanged));
                    setState(() {});
                  },
                ),
              ],
              selected: topIndex,
              onItemPressed: (index) {
                // Do anything you want to do, such as:
                if (index == topIndex) {
                  if (displayMode == PaneDisplayMode.open) {
                    setState(() => this.displayMode = PaneDisplayMode.compact);
                  } else if (displayMode == PaneDisplayMode.compact) {
                    setState(() => this.displayMode = PaneDisplayMode.open);
                  }
                }
              },
              onChanged: (index) => setState(() => topIndex = index),
              displayMode: displayMode,
              items: widget.confList
                      ?.map((config) {
                        var data = (config["doc"] as TomlDocument).toMap();
                        return PaneItem(
                            icon: const Icon(FluentIcons.configuration_solid),
                            title: Text(data["connection_string"] ?? "-"),
                            infoBadge: widget.quincyRuntime?["path"]?.status ==
                                    QuincyRuntimeStatus.active
                                ? const InfoBadge(
                                    source: Icon(FluentIcons.accept))
                                : null,
                            body: Tooltip(
                              message: (config["doc"] as TomlDocument)
                                  .toMap()["connection_string"],
                              child: ConfigDisplay(
                                path: config["path"],
                                onDelete: widget.onDelete,
                                runtime: widget.quincyRuntime?[config["path"]],
                                doc: config["doc"] as TomlDocument,
                                onConnect: widget.onConnect,
                                content:
                                    (config["doc"] as TomlDocument).toMap(),
                              ),
                            ));
                      })
                      .toList()
                      .cast<NavigationPaneItem>() ??
                  [],
            ),
          )),
    );
  }
}
