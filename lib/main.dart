import 'dart:ui';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' hide Colors;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quincy_sui/store/theme.dart';
import 'package:quincy_sui/widgets/home.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Must add this line.
  await windowManager.ensureInitialized();
  final screenSize = PlatformDispatcher.instance.views.first.physicalSize /
      PlatformDispatcher.instance.views.first.devicePixelRatio;
  WindowOptions windowOptions = WindowOptions(
    size: Size(800, 600),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,

    titleBarStyle: TitleBarStyle.hidden,
    minimumSize: Size(800, 600),
    // maximumSize: screenSize,
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
              // backgroundColor: Colors.white,
              body: Home(
                
              ),
            ),
          );
        }));
  }
}
