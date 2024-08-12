import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

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

  createExcutableFile(String targetPath) async {
    // 检查文件是否已经存在
    if (!await File(targetPath).exists()) {
      // 从assets中加载文件
      final byteData = await rootBundle.load('assets/quincy/${runtimeName}');
      final bytes = byteData.buffer.asUint8List();

      // 将文件写入应用的文件目录
      final file = File(targetPath);
      await file.writeAsBytes(bytes);
    }
  }

  create() async {
    runtimeName = getBinaryName();
    try {
      if (runtimePath == null) {
        final directory = await getApplicationDocumentsDirectory();
        runtimePath =
            '${directory.path}${Platform.pathSeparator}${runtimeName}';
        createExcutableFile(runtimePath!);
      }
      runtime =
          await Process.start(runtimePath!, ['--config-path', configPath]);
      initLogs();
      initErrorLogs();
      pid = runtime!.pid;
      if (await runtime!.exitCode != 0) {
        throw Exception("Failed to start");
      }
      status = QuincyRuntimeStatus.active;
    } catch (e) {
      print(e.toString());
      status = QuincyRuntimeStatus.failed;
    } finally {
      for (var element in StatusChangedCallBackList) {
        element(status);
      }
      _timer = Timer.periodic(Duration(seconds: 2), (timer) async {
        var preStatus = status;
        if (await runtime!.exitCode == 0) {
          status = QuincyRuntimeStatus.active;
        } else {
          status = QuincyRuntimeStatus.failed;
        }
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

  start() {}
  stop() async {
   runtime?.kill(ProcessSignal.sigstop);
  }

  restart() {
    var res = runtime?.kill(ProcessSignal.sigstop) ?? false;
    // if (!res) {
    //   throw Exception("Failed to kill process");
    // }
    this.create();
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
