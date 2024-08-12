import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart'
    hide IconButton, showDialog, Divider, Colors;
import 'package:quincy_sui/utils/quincy.dart';
import 'package:toml/toml.dart';

class ConfigDisplay extends StatelessWidget {
  Map<String, dynamic> content = {};
  TomlDocument doc;
  void Function(String key)? onDelete;
  Quincy? runtime;
  String path;
  void Function(TomlDocument doc, String path)? onConnect;
  ConfigDisplay(
      {Key? key,
      this.runtime,
      this.onDelete,
      required this.content,
      required this.path,
      this.onConnect,
      required this.doc})
      : super(key: key);

  List<Widget> showButtons(BuildContext context) {
    if (runtime?.status == QuincyRuntimeStatus.stoped) {
      return [
        Button(
            child: Text(context.tr('连接')),
            onPressed: () {
              if (onConnect == null) {
                return;
              }
              onConnect!(doc, path);
            }),
        SizedBox(
          width: 12,
        ),
        Button(child: Text(context.tr('编辑')), onPressed: () {}),
      ];
    } else if (runtime?.status == QuincyRuntimeStatus.active) {
      return [
        Button(
            child: Text(context.tr('断开')),
            onPressed: () {
              if (runtime == null) {
                return;
              }
              runtime?.stop();
            }),
        SizedBox(
          width: 12,
        ),
        Button(child: Text(context.tr('编辑')), onPressed: () {}),
      ];
    } else if (runtime?.status == QuincyRuntimeStatus.failed) {
      return [
        Button(
            child: Text(context.tr('重新连接')),
            onPressed: () {
              if (onConnect == null) {
                return;
              }
              onConnect!(doc, path);
            }),
        SizedBox(
          width: 12,
        ),
        Button(child: Text(context.tr('编辑')), onPressed: () {}),
      ];
    } else {
      return [
        Button(
            child: Text(context.tr('连接')),
            onPressed: () {
              if (onConnect == null) {
                return;
              }
              onConnect!(doc, path);
            }),
        SizedBox(
          width: 12,
        ),
        Button(child: Text(context.tr('编辑')), onPressed: () {}),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          min(MediaQuery.sizeOf(context).width / 2 - 264, 64), 58, 40, 0),
      width: MediaQuery.sizeOf(context).width,
      height: MediaQuery.sizeOf(context).height,
      alignment: Alignment.topLeft,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SelectableText(
                  "${context.tr("连接串")} : ${content["connection_string"]}",
                  style: TextStyle(fontSize: 24),
                ),
                SizedBox(
                  width: 16,
                ),
                Badge(
                  isLabelVisible: runtime?.status == QuincyRuntimeStatus.failed,
                  child: Button(
                      child: Text(context.tr('日志')),
                      onPressed: () async {
                        // print(runtime);
                        await showDialog(
                            context: context,
                            builder: (context) {
                              return ContentDialog(
                                constraints: BoxConstraints(
                                    maxWidth: MediaQuery.sizeOf(context).width),
                                title: Text(context.tr('日志')),
                                actions: [
                                  Button(
                                      child: Text(context.tr('了解')),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      })
                                ],
                                content: Container(
                                  width: MediaQuery.sizeOf(context).width,
                                  height: MediaQuery.sizeOf(context).height,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: ListView.builder(
                                            padding: EdgeInsets.fromLTRB(
                                                0, 0, 10, 0),
                                            itemCount:
                                                (runtime?.logs.length ?? 0),
                                            itemBuilder: (c, i) {
                                              return Text(
                                                  runtime?.logs?[i] ?? "-");
                                            }),
                                      ),
                                      SizedBox(
                                        width: 24,
                                      ),
                                      Expanded(
                                        child: ListView.builder(
                                            padding: EdgeInsets.fromLTRB(
                                                0, 0, 10, 0),
                                            itemCount:
                                                (runtime?.errorLogs.length ??
                                                    0),
                                            itemBuilder: (c, i) {
                                              return Text(
                                                  runtime?.errorLogs?[i] ??
                                                      "-");
                                            }),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            });
                      }),
                ),
              ],
            ),
            runtime?.status == QuincyRuntimeStatus.active
                ? Icon(
                    FluentIcons.plug_connected,
                    color: Colors.green,
                  )
                : runtime?.status == QuincyRuntimeStatus.failed
                    ? Icon(FluentIcons.critical_error_solid, color: Colors.red)
                    : Icon(FluentIcons.plug_disconnected),
            SizedBox(
              height: 24,
            ),
            SelectableText("${context.tr("认证类型")} : UsersFile"),
            SelectableText("${context.tr('用户名')} : ${content["authentication"]["username"]}"),
            // SelectableText("密码 : ${content["authentication"]["password"]}"),
            SelectableText("${context.tr('密码')} : ********"),
            SelectableText(
                "${context.tr('信任证书' )}: ${content["authentication"]["trusted_certificates"]}"),
            SelectableText("${context.tr('路由')} : ${content["network"]["routes"]}"),
            SizedBox(
              height: 16,
            ),
            Divider(),
            SizedBox(
              height: 16,
            ),
            SelectableText("MTU : ${content["connection"]["mtu"]}"),
            SelectableText(
                "${context.tr('连接超时')} : ${content["connection"]["connection_timeout"]}"),
            SelectableText(
                "Keep Alive Interval : ${content["connection"]["keep_alive_interval"]}"),
            SelectableText(
                "${context.tr('发送帧大小')} : ${content["connection"]["send_buffer_size"]}"),
            SelectableText(
                "${context.tr('接收帧大小')} : ${content["connection"]["recv_buffer_size"]}"),
            SelectableText("${context.tr('日志级别')} : ${content["log"]["level"]}"),
            SizedBox(
              height: 24,
            ),
            Container(
              height: 30,
              width: MediaQuery.sizeOf(context).width,
              child: Row(
                children: [
                  ...showButtons(context),
                  SizedBox(
                    width: 16,
                  ),
                  IconButton(
                      icon: Icon(
                        color: Colors.red,
                        Icons.delete),
                      onPressed: () {
                        if (onDelete == null) {
                          return;
                        }
                        onDelete!(path);
                      })
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
