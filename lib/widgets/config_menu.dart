import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart'
    hide ButtonStyle, Colors, showDialog, Tooltip;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quincy_sui/store/theme.dart';
import 'package:quincy_sui/utils/quincy.dart';
import 'package:quincy_sui/widgets/config_display.dart';
import 'package:quincy_sui/widgets/config_form.dart';
import 'package:toml/toml.dart';
import 'package:window_manager/window_manager.dart';

class ConfigMenu extends StatefulWidget {
  List<Map<String, dynamic>>? confList;
  Map<String, Quincy>? quincyRuntime;
  Directory? confDir;
  void Function(TomlDocument doc, String path)? onConnect;
  void Function(TomlDocument doc)? onChanged;
  ConfigMenu(
      {Key? key,
      this.quincyRuntime,
      this.confList,
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
      child: NavigationView(
        appBar: NavigationAppBar(
            title: InkWell(
              onTapDown: (detail) {
                windowManager.startDragging();
              },
              child: Container(
                width: MediaQuery.sizeOf(context).width,
                child: Text('Quincy Sui'),
              ),
            ),
            leading: Container(child: Icon(FluentIcons.database)),
            actions: Container(
              width: 240,
              height: 50,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.center,
                    width: 100,
                    height: 50,
                    child: BlocBuilder<ThemeModeCubit, ThemeMode>(builder: (c, v) {
                      return Container(
                        child: ToggleSwitch(
                          onChanged: (v) {
                            context.read<ThemeModeCubit>().toggle();
                          },
                          content: v == ThemeMode.dark ? Icon(FluentIcons.clear_night) : Icon(Icons.sunny),
                          checked: v == ThemeMode.dark,
                        ),
                      );
                    }),
                  ),
                  Expanded(
                      child: HyperlinkButton(
                    style: ButtonStyle(
                        foregroundColor: WidgetStatePropertyAll(
                            Theme.of(context).textTheme.bodyMedium?.color)),
                    onPressed: () async {
                      await windowManager.minimize();
                    },
                    child: Container(
                      height: MediaQuery.sizeOf(context).height,
                      // width: 50,
                      child: Icon(FluentIcons.calculator_subtract),
                    ),
                  )),
                  Expanded(
                    child: HyperlinkButton(
                      style: ButtonStyle(
                          foregroundColor: WidgetStatePropertyAll(
                              Theme.of(context).textTheme.bodyMedium?.color)),
                      onPressed: () async {
                        if (await windowManager.isMaximized()) {
                          windowManager.unmaximize();
                        } else {
                          await windowManager.maximize();
                        }
                      },
                      child: Container(
                        height: MediaQuery.sizeOf(context).height,
                        // width: 50,
                        child: Icon(FluentIcons.square_shape),
                      ),
                    ),
                  ),
                  Expanded(
                    child: HyperlinkButton(
                      style: ButtonStyle(
                          foregroundColor: WidgetStatePropertyAll(
                              Theme.of(context).textTheme.bodyMedium?.color)),
                      onPressed: () async {
                        try {
                          if (mounted == false) {
                            return;
                          }
                          await windowManager.close();
                        } catch (e) {
                          if (mounted == false) {
                            return;
                          }
                          // await windowManager.destroy();
                        }
                      },
                      child: Container(
                        height: MediaQuery.sizeOf(context).height,
                        // width: 50,
                        child: Icon(FluentIcons.cancel),
                      ),
                    ),
                  ),
                ],
              ),
            )),
        pane: NavigationPane(
          footerItems: [
            PaneItem(
              icon: const Icon(FluentIcons.settings),
              title: const Text('Settings'),
              body: Container(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                child: Text("Config path is in ${widget.confDir ?? "-"}"),
              ),
            ),
            PaneItemAction(
              icon: const Icon(FluentIcons.add),
              title: const Text('Add New Item'),
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
                            ? const InfoBadge(source: Icon(FluentIcons.accept))
                            : null,
                        body: Tooltip(
                          message: (config["doc"] as TomlDocument)
                              .toMap()["connection_string"],
                          child: ConfigDisplay(
                            path: config["path"],
                            runtime: widget.quincyRuntime?[config["path"]],
                            doc: config["doc"] as TomlDocument,
                            onConnect: widget.onConnect,
                            content: (config["doc"] as TomlDocument).toMap(),
                          ),
                        ));
                  })
                  .toList()
                  .cast<NavigationPaneItem>() ??
              [],
        ),
      ),
    );
  }
}
