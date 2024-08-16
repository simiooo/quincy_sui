import 'dart:io';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' hide Colors;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:quincy_sui/store/quincy_store.dart';
import 'package:quincy_sui/store/theme.dart';
import 'package:quincy_sui/utils/startup.dart';
import 'package:quincy_sui/utils/tray.dart';
import 'package:quincy_sui/widgets/home.dart';
import 'package:super_clipboard/super_clipboard.dart';
import 'package:window_manager/window_manager.dart';
import 'package:windows_single_instance/windows_single_instance.dart';

final GlobalKey rootKey = GlobalKey();
var tomlFormat = const SimpleFileFormat(
    windowsFormats: ["text/x-toml"],
    macosFormats: ["text/x-toml"],
    linuxFormats: ["text/x-toml"],
    iosFormats: ["text/x-toml"],
    androidFormats: ["text/x-toml"],
    uniformTypeIdentifiers: ['com.barebones.bbedit.toml-source'],
    mimeTypes: ["text/x-toml"]);
void main(args) async {
  WidgetsFlutterBinding.ensureInitialized();

  await EasyLocalization.ensureInitialized();

  launchAtStartup.setup(
    appName: "Quincy SUI",
    appPath: Platform.resolvedExecutable,
    // Set packageName parameter to support MSIX.
    packageName: 'top.squirrelso.networks.quincySui',
  );

  initialStartup();

  await WindowsSingleInstance.ensureSingleInstance(args, "quincy_sui_instance",
      onSecondWindow: (args) {});
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
  runApp(
    EasyLocalization(
        supportedLocales: [
          Locale('en', 'US'),
          Locale('ja', 'JP'),
          Locale('zh', 'CN')
        ],
        path:
            'assets/translations', // <-- change the path of the translation files
        fallbackLocale: Locale('en', 'US'),
        child: const MyApp()),
  );
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
        providers: [
          BlocProvider(create: (_) => QuincyStoreCubit()),
          BlocProvider(create: (_) => ThemeModeCubit())
        ],
        child: BlocBuilder<ThemeModeCubit, ThemeMode>(builder: (c, v) {
          return FluentApp(
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
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
