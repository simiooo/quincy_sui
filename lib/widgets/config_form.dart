import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
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
  TomlDocument? initialValue;
  void Function(TomlDocument doc)? onChanged;

  ConfigForm({
    Key? key,
    this.onChanged,
    this.initialValue,
  }) : super(key: key);

  @override
  _ConfigFormState createState() => _ConfigFormState();
}

class _ConfigFormState extends State<ConfigForm> {
  String? logLevel = 'info';
  final _formKey = GlobalKey<FormBuilderState>();
  List<File> certPath = [];
  Map<String, dynamic> _internalValue = {
    "log_level": "info"
  };
  Map<String, TextEditingController?> fieldsController = {
    "connection_string": TextEditingController(),
    "username": TextEditingController(),
    "password": TextEditingController(),
    "routes": TextEditingController(),
    "mtu": TextEditingController(),
    "send_buffer_size": TextEditingController(),
    "recv_buffer_size": TextEditingController(),
    // "": TextEditingController(),
    // "": TextEditingController(),
  };

  initForm() {
    var payload = widget.initialValue?.toMap() ?? {};
    if (widget.initialValue == null) {
      return;
    }
    var value = {
      "connection_string": payload["connection_string"],
      "username": payload["authentication"]?["username"],
      "password": payload["authentication"]?["password"],
      "trusted_certificates": (payload["authentication"]
                  ?["trusted_certificates"] as List<dynamic>? ??
              [])
          .map<File>((el) {
        return File(el as String);
      }).toList(),
      "mtu": (payload["connection"]?["mtu"] is int) ? (payload["connection"]?["mtu"].toString()) : payload["connection"]?["mtu"],
      "send_buffer_size": (payload["connection"]?["send_buffer_size"] is int) ? (payload["connection"]?["send_buffer_size"].toString()) : payload["connection"]?["send_buffer_size"],
      "recv_buffer_size": (payload["connection"]?["recv_buffer_size"] is int) ? (payload["connection"]?["recv_buffer_size"].toString()) : payload["connection"]?["recv_buffer_size"],
      "routes": (payload["network"]?["routes"] ?? []).join(','),
      "log_level": payload["log"]?["level"],
    };

    _internalValue = value;
    fieldsController.forEach((action, controller) {
      switch (action) {
        default:
          if (controller == null) {
            return;
          }
          controller.text = _internalValue?[action].toString() ?? "";
      }
    });
  }

  @override
  void didUpdateWidget(covariant ConfigForm oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initForm();
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      constraints: BoxConstraints.expand(
        height: MediaQuery.sizeOf(context).height,
        width: max(MediaQuery.sizeOf(context).width / 2, 400),
      ),
      title: Text(context.tr('客户端配置')),
      content: Container(
        width: MediaQuery.sizeOf(context).width,
        height: MediaQuery.sizeOf(context).height,
        child: FormBuilder(
          key: _formKey,
          onChanged: () {
            _formKey.currentState?.save();
            _internalValue = _formKey.currentState?.value ?? {};
            setState(() {
              
            });
          },
          initialValue: _internalValue,
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
                        controller: fieldsController["connection_string"],
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
                        controller: fieldsController["username"],
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
                        controller: fieldsController["password"],
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
                      return v ??
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
                          context.tr('加入证书'),
                        ),
                        onPressed: () async {
                          FilePickerResult? result =
                              await FilePicker.platform.pickFiles(
                            allowMultiple: true,
                            type: FileType.custom,
                            allowedExtensions: ['pem'],
                          );
                          List<File> files = [];
                          if (result != null) {
                            files = result.paths
                                .map((path) => File(path!))
                                .toList();
                          } else {
                            // User canceled the picker
                          }
                          // 处理下载证书的逻辑
                          field.didChange(files);
                          setState(() {});
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
                  child: (_internalValue["trusted_certificates"] ==
                              null ||
                          _internalValue["trusted_certificates"]!
                              .isEmpty)
                      ? InfoBar(
                          title: Text(context.tr('暂未获取到证书')),
                          content: Text(context.tr('请手动添加证书')),
                          severity: InfoBarSeverity.info,
                          isLong: true,
                        )
                      : ListView.separated(
                          itemCount: _internalValue["trusted_certificates"]!.length,
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
                                  Text(_internalValue["trusted_certificates"]![index]
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
                                              if (_formKey.currentState ==
                                                  null) {
                                                return;
                                              }
                                              var value = _internalValue[
                                                      "trusted_certificates"] ??
                                                  [];
                                              value.removeAt(index);
                                              _formKey.currentState!
                                                  .patchValue({
                                                "trusted_certificates": value
                                              });
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
                        controller: fieldsController["routes"],
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
                  child: Text(context.tr('可选')),
                  alignment: Alignment.centerLeft,
                ),
                InfoLabel(
                  label: 'Enter MTU:',
                  child: FormBuilderField(
                    name: 'mtu',
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.integer(),
                      FormBuilderValidators.max(0x1000),
                    ]),
                    builder: (FormFieldState<dynamic> field) {
                      return TextBox(
                        controller: fieldsController["mtu"],
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
                // InfoLabel(
                //   label: 'Enter connection timeout:',
                //   child: FormBuilderField(
                //     name: 'connection_timeout',
                //     builder: (FormFieldState<dynamic> field) {
                //       return TextBox(
                //         onChanged: (value) {
                //           field.didChange(value);
                //         },
                //         decoration: BoxDecoration(
                //           border: field.hasError
                //               ? Border.all(color: Colors.red)
                //               : null,
                //         ),
                //         placeholder: 'Connection timeout ( default: 30s )',
                //       );
                //     },
                //   ),
                // ),
                // InfoLabel(
                //   label: 'Enter keep alive interval:',
                //   child: FormBuilderField(
                //     name: 'keep_alive_interval',
                //     builder: (FormFieldState<dynamic> field) {
                //       return TextBox(
                //         onChanged: (value) {
                //           field.didChange(value);
                //         },
                //         decoration: BoxDecoration(
                //           border: field.hasError
                //               ? Border.all(color: Colors.red)
                //               : null,
                //         ),
                //         placeholder: 'Keep alive interval ( default: 25s )',
                //       );
                //     },
                //   ),
                // ),
                InfoLabel(
                  label: 'Enter send_buffer_size:',
                  child: FormBuilderField<String>(
                    name: 'send_buffer_size',
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.integer(),
                      
                    ]),
                    builder: (FormFieldState<dynamic> field) {
                      return TextBox(
                        controller: fieldsController["send_buffer_size"],
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
                  child: FormBuilderField<String>(
                    name: 'recv_buffer_size',
                    builder: (FormFieldState<dynamic> field) {
                      return TextBox(
                        controller: fieldsController["recv_buffer_size"],
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
                            child: Text(context.tr('Info')),
                            value: 'info',
                          ),
                          ComboBoxItem(
                            child: Text(context.tr('Error')),
                            value: 'error',
                          ),
                        ],
                        placeholder: Text(context.tr('Log level')),
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
          child: Text(context.tr('取消')),
          onPressed: () {
            Navigator.pop(context, 'cancel');
            // Delete file here
          },
        ),
        FilledButton(
          child: Text(context.tr('保存')),
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
                    "trusted_certificates":
                        (payload["trusted_certificates"] as List<File>? ?? []).map((File el) => el.path).toList(),
                  },
                  "connection": {
                    "mtu": (payload["mtu"] != null && payload["mtu"] is String) ? int.parse(payload["mtu"]) : 1400,
                    // "connection_timeout": payload["connection_timeout"] ?? "30s",
                    // "keep_alive_interval": payload["keep_alive_interval"] ?? "25s",
                    "send_buffer_size": (payload["send_buffer_size"] != null && payload["send_buffer_size"] is String) ? int.parse(payload["send_buffer_size"]) : 2097152,
                    "recv_buffer_size": (payload["recv_buffer_size"] != null && payload["recv_buffer_size"] is String) ? int.parse(payload["recv_buffer_size"]) : 2097152,
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
                        title: Text(context.tr('错误')),
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:
                              _formKey.currentState?.errors?.entries?.map((e) {
                                    return Text("${e.key}: ${e.value}");
                                  }).toList() ??
                                  [],
                        ),
                        actions: [
                          FilledButton(
                            child: Text(context.tr('了解')),
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
