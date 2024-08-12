import 'dart:ui';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' hide Colors;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quincy_sui/store/theme.dart';
import 'package:quincy_sui/utils/tray.dart';
import 'package:quincy_sui/widgets/home.dart';
import 'package:super_clipboard/super_clipboard.dart';
import 'package:window_manager/window_manager.dart';

final GlobalKey rootKey = GlobalKey();
var tomlFormat = const SimpleFileFormat(
    windowsFormats: ["text/x-toml"],
    macosFormats: ["text/x-toml"],
    linuxFormats: ["text/x-toml"],
    iosFormats: ["text/x-toml"],
    androidFormats: ["text/x-toml"],
    uniformTypeIdentifiers: ['com.barebones.bbedit.toml-source'],
    mimeTypes: ["text/x-toml"]);
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Must add this line.
  await windowManager.ensureInitialized();
  initSystemTray();
  WindowOptions windowOptions = const WindowOptions(
    size: Size(800, 600),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
    minimumSize: Size(800, 600),
  );
  windowManager.setResizable(true);
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [BlocProvider(create: (_) => ThemeModeCubit())],
        child: BlocBuilder<ThemeModeCubit, ThemeMode>(builder: (c, v) {
          return FluentApp(
            title: 'Quincy Sui',
            theme: FluentThemeData(
              accentColor: Colors.green,
            ),
            darkTheme: FluentThemeData.dark(),
            themeMode: v,
            home: Scaffold(
              key: rootKey,
              // backgroundColor: Colors.white,
              body: Home(),
            ),
          );
        }));
  }
}
