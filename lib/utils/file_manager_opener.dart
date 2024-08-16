import 'dart:io';

Future<String?> detectDesktopEnvironment() async {
  // 尝试通过环境变量检测桌面环境
  if (Platform.environment.containsKey('DESKTOP_SESSION')) {
    return Platform.environment['DESKTOP_SESSION'];
  }

  // 尝试通过运行 shell 命令检测桌面环境
  try {
    var result = await Process.run('echo', ['\$XDG_CURRENT_DESKTOP']);
    if (result.exitCode == 0 && result.stdout != null) {
      return result.stdout.trim();
    }
  } catch (e) {
    print("Error detecting desktop environment: $e");
  }

  return null;
}

void fileMangerOpen(String path) async {
  if (Platform.isWindows) {
    Process.run('explorer', [path]);
  } else if (Platform.isLinux) {
    String? desktopEnvironment = await detectDesktopEnvironment();
    if (desktopEnvironment == null) {
      print("Unable to detect desktop environment.");
      return;
    }
    String fileManagerCommand;

    switch (desktopEnvironment.toLowerCase()) {
      case 'gnome':
      case 'ubuntu':
        fileManagerCommand = 'nautilus';
        break;
      case 'kde':
        fileManagerCommand = 'dolphin';
        break;
      case 'xfce':
        fileManagerCommand = 'thunar';
        break;
      case 'mate':
        fileManagerCommand = 'caja';
        break;
      case 'cinnamon':
        fileManagerCommand = 'nemo';
        break;
      case 'lxde':
        fileManagerCommand = 'pcmanfm';
        break;
      case 'lxqt':
        fileManagerCommand = 'pcmanfm-qt';
        break;
      case 'deepin':
        fileManagerCommand = 'dde-file-manager';
        break;
      default:
        print("Unsupported desktop environment: $desktopEnvironment");
        return;
    }
    Process.run(fileManagerCommand, [path]);
  }
}
