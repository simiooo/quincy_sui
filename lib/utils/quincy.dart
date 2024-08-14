import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_launcher_icons/custom_exceptions.dart';
import 'package:mustache_template/mustache.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quincy_sui/utils/windowsTaskXml.dart';

enum QuincyRuntimeStatus {
  stoped,
  active,
  failed,
}

class Quincy {
  String? runtimePath;
  Timer? _timer;
  String? runtimeName;
  String configPath;
  int? pid;
  QuincyRuntimeStatus status = QuincyRuntimeStatus.stoped;
  Process? runtime;
  List<String> logs = [];
  List<String> errorLogs = [];

  Quincy({this.runtimePath, required this.configPath}) {
    create();
  }

  Quincy._createAsync({this.runtimePath, required this.configPath});

  static Future<Quincy> createInstance({runtimePath, required configPath}) async {
    Quincy component =  Quincy._createAsync(runtimePath: runtimePath, configPath: configPath);
    await component.create();
    return component;
  }

  String removeAnsiEscapeCodes(String text) {
    return text.replaceAll(RegExp(r'\x1B\[([0-9;]*[mGKH])'), '');
  }

  String getBinaryName() {
    if (Platform.isWindows) {
      return "quincy_client_windows_x86_64.exe";
    } else if (Platform.isLinux) {
      return "quincy_client_linux_x86_64";
    } else if (Platform.isMacOS) {
      return "quincy_client_macos_arm64";
    } else {
      throw Exception("暂不支持");
    }
  }

  List<void Function(List<String> logs, List<String> errorLogs)>
      logHandlerList = [];
  onLogChanged(
      void Function(List<String> logs, List<String> errorLogs) loghandler) {
    logHandlerList.add(loghandler);
  }

  createExcutableFile(String targetPath, {required String wintunPath}) async {
    // 检查文件是否已经存在
    if (!await File(targetPath).exists()) {
      // 从assets中加载文件
      final byteData = await rootBundle.load('assets/quincy/${runtimeName}');
      final bytes = byteData.buffer.asUint8List();

      // 将文件写入应用的文件目录
      final file = File(targetPath);
      await file.writeAsBytes(bytes);
      if (Platform.isWindows) {
        final wintun = await rootBundle.load("assets/quincy/wintun.dll");
        final bytes = wintun.buffer.asUint8List();
        final wintunFile = File(wintunPath);
        await wintunFile.writeAsBytes(bytes);
      }
    }
  }

  @deprecated
  Future<String> writeWindowsTaskXml() async {
    // var taskName = "quincy_sui_task.xml";
    var template = Template(windowsTaskXmlSource, name: "quincy_sui_task.xml");
    var content = template.renderString({
      "runCommand": runtimePath,
      "arguments": "--config-path $configPath",
    });
    var appDocumentsDir = await getApplicationDocumentsDirectory();
    var xmlTask = File(join(appDocumentsDir.path, "quincy_sui_task.xml"));
    await xmlTask.writeAsString(content);
    return join(appDocumentsDir.path, "quincy_sui_task.xml");
  }

  create() async {
    runtimeName = getBinaryName();
    try {
      if (runtimePath == null) {
        final directory = await getApplicationDocumentsDirectory();
        runtimePath = join(directory.path, runtimeName);
        createExcutableFile(runtimePath!,
            wintunPath: join(directory.path, "wintun.dll"));
      }

      if (!await File(configPath).exists()) {
        throw const FileNotFoundException("No Configuration file found");
      }
      if (!await File(runtimePath ?? '__no_excutable__').exists()) {
        {
          throw const FileNotFoundException("No excutable file found");
        }
      }
      if(Platform.isLinux) {
        await Process.run('chmod', ['755', runtimePath!]);
      }
      runtime = await Process.start(
        runtimePath!,
        ['--config-path', configPath],
      );
      status = QuincyRuntimeStatus.active;
      initLogs();
      initErrorLogs();
      pid = runtime!.pid;
      if (await runtime!.exitCode != 0) {
        throw Exception("Failed to start");
      }
    } catch (e) {
      errorLogs.add(removeAnsiEscapeCodes(e.toString()));
      for (var cb in logHandlerList) {
        cb(logs, errorLogs);
      }
      status = QuincyRuntimeStatus.failed;
    } finally {
      for (var element in StatusChangedCallBackList) {
        element(status);
      }
      _timer = Timer.periodic(Duration(seconds: 2), (timer) async {
        var preStatus = status;
        if (runtime == null) {
          status = QuincyRuntimeStatus.failed;
          return;
        }
        if (await runtime!.exitCode == 0) {
          status = QuincyRuntimeStatus.stoped;
        } else if (await runtime!.exitCode != 0) {
          status = QuincyRuntimeStatus.failed;
        } else {}
        if (preStatus != status) {
          for (var element in StatusChangedCallBackList) {
            element(status);
          }
        }
      });
    }
  }

  List<void Function(QuincyRuntimeStatus status)> StatusChangedCallBackList =
      [];

  onStatusChanged(void Function(QuincyRuntimeStatus status)? handler) {
    if (handler == null) {
      return;
    }
    StatusChangedCallBackList.add(handler);
  }

  void dispose() {
    // 取消定时器
    _timer?.cancel();
  }

  stop() async {
    return runtime?.kill(ProcessSignal.sigstop);
  }

  restart() async {
    var res = runtime?.kill(ProcessSignal.sigstop) ?? false;
    // if (!res) {
    //   throw Exception("Failed to kill process");
    // }
    await create();
  }

  initLogs() {
    runtime?.stdout.transform(utf8.decoder).forEach((content) {
      logs.add(removeAnsiEscapeCodes(content));
      for (var cb in logHandlerList) {
        cb(logs, errorLogs);
      }
    });
  }

  initErrorLogs() {
    runtime?.stderr.transform(utf8.decoder).forEach((content) {
      errorLogs.add(removeAnsiEscapeCodes(content));
      for (var cb in logHandlerList) {
        cb(logs, errorLogs);
      }
    });
  }
}
