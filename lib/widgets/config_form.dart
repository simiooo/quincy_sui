import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart'
    hide
        Colors,
        FilledButton,
        Button,
        Divider,
        Card,
        IconButton,
        ButtonStyle,
        showDialog;
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:toml/toml.dart';

class ConfigForm extends StatefulWidget {
  Map<String, dynamic>? initData;
  void Function(TomlDocument doc)? onChanged;

  ConfigForm({Key? key, this.onChanged, this.initData}) : super(key: key);

  @override
  _ConfigFormState createState() => _ConfigFormState();
}

class _ConfigFormState extends State<ConfigForm> {
  String? logLevel = 'info';
  final _formKey = GlobalKey<FormBuilderState>();
  List<File> certPath = [];

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      constraints: BoxConstraints.expand(
        height: MediaQuery.sizeOf(context).height,
        width: max(MediaQuery.sizeOf(context).width / 2, 400),
      ),
      title: const Text('客户端配置'),
      content: Container(
        width: MediaQuery.sizeOf(context).width,
        height: MediaQuery.sizeOf(context).height,
        child: FormBuilder(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(0, 4, 10, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InfoLabel(
                  label: 'Enter connection string:',
                  child: FormBuilderField(
                    name: 'connection_string',
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                    ]),
                    builder: (FormFieldState<dynamic> field) {
                      return TextBox(
                        onChanged: (value) {
                          field.didChange(value);
                        },
                        decoration: BoxDecoration(
                            border: field.hasError
                                ? Border.all(color: Colors.red)
                                : null),
                        placeholder: 'Connection string',
                        // expands: false,
                      );
                    },
                  ),
                ),
                Divider(
                  direction: Axis.vertical,
                  size: 4,
                ),
                // InfoLabel(
                //   label: 'Select authentication type:',
                //   child: FormBuilderField(
                //     name: 'auth_type',
                //     validator: FormBuilderValidators.compose([
                //       FormBuilderValidators.required(),
                //     ]),
                //     builder: (FormFieldState<dynamic> field) {
                //       return ComboBox(
                //         placeholder: Text('Auth type'),
                //         items: [
                //           ComboBoxItem(
                //             child: Text("UsersFile"),
                //             value: "UsersFile",
                //           )
                //         ],
                //         onChanged: (value) {
                //           field.didChange(value);
                //         },
                //         value: field.value,
                //         style: TextStyle(
                //           color: field.hasError ? Colors.red : null,
                //         ),
                //       );
                //     },
                //   ),
                // ),
                InfoLabel(
                  label: 'Enter your username:',
                  child: FormBuilderField(
                    name: 'username',
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                    ]),
                    builder: (FormFieldState<dynamic> field) {
                      return TextBox(
                        onChanged: (value) {
                          field.didChange(value);
                        },
                        decoration: BoxDecoration(
                          border: field.hasError
                              ? Border.all(color: Colors.red)
                              : null,
                        ),
                        placeholder: 'Username',
                      );
                    },
                  ),
                ),
                InfoLabel(
                  label: 'Enter your password:',
                  child: FormBuilderField(
                    name: 'password',
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                    ]),
                    builder: (FormFieldState<dynamic> field) {
                      return PasswordBox(
                        onChanged: (value) {
                          field.didChange(value);
                        },
                        decoration: BoxDecoration(
                          border: field.hasError
                              ? Border.all(color: Colors.red)
                              : null,
                        ),
                        placeholder: 'Password',
                        revealMode: PasswordRevealMode.hidden,
                      );
                    },
                  ),
                ),
                InfoLabel(
                  label: 'Enter trusted certificates:',
                  child: FormBuilderField(
                    name: 'trusted_certificates',
                    validator: (List<File>? v) {
                      return (v?.isNotEmpty != null && v!.isNotEmpty)
                          ? null
                          : "";
                    },
                    valueTransformer: ((List<File>? v) {
                      return v?.map((el) {
                            return el.path;
                          }).toList() ??
                          [];
                    }),
                    builder: (FormFieldState<dynamic> field) {
                      return Button(
                        style: field.hasError
                            ? ButtonStyle(
                                shape: WidgetStatePropertyAll(
                                    RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(3),
                                        side: BorderSide(color: Colors.red))))
                            : null,
                        child: Text(
                          '加入证书',
                        ),
                        onPressed: () async {
                          FilePickerResult? result =
                              await FilePicker.platform.pickFiles(
                            allowMultiple: true,
                            type: FileType.custom,
                            allowedExtensions: ['pem'],
                          );
                          if (result != null) {
                            List<File> files = result.paths
                                .map((path) => File(path!))
                                .toList();
                            certPath.addAll(files);
                            setState(() {});
                          } else {
                            // User canceled the picker
                          }
                          // 处理下载证书的逻辑
                          field.didChange(certPath);
                        },
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                Container(
                  width: MediaQuery.sizeOf(context).width,
                  height: 80,
                  child: certPath.isEmpty
                      ? InfoBar(
                          title: const Text('暂未获取到证书'),
                          content: const Text('请手动添加证书'),
                          severity: InfoBarSeverity.info,
                          isLong: true,
                        )
                      : ListView.separated(
                          itemCount: certPath.length,
                          separatorBuilder: (c, i) {
                            return Container(
                              width: 8,
                              height: 1,
                            );
                          },
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            return Card(
                              // width: 60,
                              // height: 20,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(certPath[index]
                                      .path
                                      .split(Platform.pathSeparator)
                                      .last),
                                  Row(
                                    children: [
                                      IconButton(
                                          icon: Icon(
                                            FluentIcons.delete,
                                            size: 18.0,
                                            color: Colors.red,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              certPath.removeAt(index);
                                            });
                                          })
                                    ],
                                  )
                                ],
                              ),
                            );
                          }),
                ),
                Divider(
                  direction: Axis.vertical,
                  size: 4,
                ),
                InfoLabel(
                  label: 'Enter Routes:',
                  child: FormBuilderField(
                    name: 'routes',
                    valueTransformer: (String? value) {
                      return value?.split(",")?.map((e) {
                        return e.trim();
                      }).takeWhile((e) {
                        return e.isNotEmpty;
                      }).toList();
                    },
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                    ]),
                    builder: (FormFieldState<dynamic> field) {
                      return TextBox(
                        onChanged: (value) {
                          field.didChange(value);
                        },
                        decoration: BoxDecoration(
                          border: field.hasError
                              ? Border.all(color: Colors.red)
                              : null,
                        ),
                        placeholder:
                            'Routes, comma seperated. \nExample: 10.0.1.0/24,10.11.12.0/24',
                        minLines: 3,
                        maxLines: 6,
                      );
                    },
                  ),
                ),
                Divider(
                  direction: Axis.vertical,
                  size: 18,
                ),
                Align(
                  child: Text('可选'),
                  alignment: Alignment.centerLeft,
                ),
                InfoLabel(
                  label: 'Enter MTU:',
                  child: FormBuilderField(
                    name: 'mtu',
                    builder: (FormFieldState<dynamic> field) {
                      return TextBox(
                        onChanged: (value) {
                          field.didChange(value);
                        },
                        decoration: BoxDecoration(
                          border: field.hasError
                              ? Border.all(color: Colors.red)
                              : null,
                        ),
                        placeholder: 'MTU (default = 1400)',
                      );
                    },
                  ),
                ),
                InfoLabel(
                  label: 'Enter connection timeout:',
                  child: FormBuilderField(
                    name: 'connection_timeout',
                    builder: (FormFieldState<dynamic> field) {
                      return TextBox(
                        onChanged: (value) {
                          field.didChange(value);
                        },
                        decoration: BoxDecoration(
                          border: field.hasError
                              ? Border.all(color: Colors.red)
                              : null,
                        ),
                        placeholder: 'Connection timeout ( default: 30s )',
                      );
                    },
                  ),
                ),
                InfoLabel(
                  label: 'Enter keep alive interval:',
                  child: FormBuilderField(
                    name: 'keep_alive_interval',
                    builder: (FormFieldState<dynamic> field) {
                      return TextBox(
                        onChanged: (value) {
                          field.didChange(value);
                        },
                        decoration: BoxDecoration(
                          border: field.hasError
                              ? Border.all(color: Colors.red)
                              : null,
                        ),
                        placeholder: 'Keep alive interval ( default: 25s )',
                      );
                    },
                  ),
                ),
                InfoLabel(
                  label: 'Enter send_buffer_size:',
                  child: FormBuilderField(
                    name: 'send_buffer_size',
                    builder: (FormFieldState<dynamic> field) {
                      return TextBox(
                        onChanged: (value) {
                          field.didChange(value);
                        },
                        decoration: BoxDecoration(
                          border: field.hasError
                              ? Border.all(color: Colors.red)
                              : null,
                        ),
                        placeholder: 'send_buffer_size (default = 2097152)',
                      );
                    },
                  ),
                ),
                InfoLabel(
                  label: 'Enter recv_buffer_size:',
                  child: FormBuilderField(
                    name: 'recv_buffer_size',
                    builder: (FormFieldState<dynamic> field) {
                      return TextBox(
                        onChanged: (value) {
                          field.didChange(value);
                        },
                        decoration: BoxDecoration(
                          border: field.hasError
                              ? Border.all(color: Colors.red)
                              : null,
                        ),
                        placeholder: 'recv_buffer_size (default = 2097152)',
                      );
                    },
                  ),
                ),
                InfoLabel(
                  label: 'Select log level:',
                  child: FormBuilderField(
                    name: 'log_level',
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                    ]),
                    builder: (FormFieldState<dynamic> field) {
                      return ComboBox(
                        items: [
                          ComboBoxItem(
                            child: Text('Info'),
                            value: 'info',
                          ),
                          ComboBoxItem(
                            child: Text('Error'),
                            value: 'error',
                          ),
                        ],
                        placeholder: Text('Log level'),
                        onChanged: (v) {
                          field.didChange(v);
                        },
                        value: field.value,
                        style: TextStyle(
                          color: field.hasError ? Colors.red : null,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        Button(
          child: const Text('取消'),
          onPressed: () {
            Navigator.pop(context, 'cancel');
            // Delete file here
          },
        ),
        FilledButton(
          child: const Text('保存'),
          onPressed: () {
            if (_formKey.currentState?.saveAndValidate != null &&
                _formKey.currentState!.saveAndValidate()) {
              if (widget.onChanged != null) {
                var payload = _formKey.currentState?.value ?? {};
                var result = {
                  "connection_string": payload["connection_string"] ?? "",
                  "authentication": {
                    "username": payload["username"] ?? "",
                    "password": payload["password"] ?? "",
                    "trusted_certificates": payload["trusted_certificates"] ?? "",
                  },
                  "connection": {
                    "mtu": payload["mtu"] ?? 1400,
                    "connection_timeout": payload["connection_timeout"] ?? "30s",
                    "keep_alive_interval": payload["keep_alive_interval"] ?? "25s",
                    "send_buffer_size": payload["send_buffer_size"] ?? 2097152,
                    "recv_buffer_size": payload["recv_buffer_size"] ?? 2097152,
                  },
                  "network": {
                    "routes": payload["routes"],
                  },
                  "log": {"level": payload["log_level"]}
                };
                widget.onChanged!(TomlDocument.fromMap(result));
              }
              Navigator.pop(context, 'confirm');
            } else {
              showDialog(
                  context: context,
                  builder: (context) => ContentDialog(
                        title: Text('错误'),
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _formKey.currentState?.errors?.entries?.map((e) {
                          return Text("${e.key}: ${e.value}");
                        }).toList() ?? [],) ,
                        actions: [
                          FilledButton(
                            child: const Text('了解'),
                            onPressed: () =>
                                Navigator.pop(context, 'User canceled dialog'),
                          ),
                        ],
                      ));
            }
          },
        ),
      ],
    );
  }
}
