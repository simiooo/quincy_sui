import 'package:easy_localization/easy_localization.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' hide ButtonStyle, IconButton, ListTile;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quincy_sui/main.dart';
import 'package:quincy_sui/store/theme.dart';
import 'package:window_manager/window_manager.dart';

final menuController = FlyoutController();

class WindowControl extends StatelessWidget {
  const WindowControl({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 298,
      height: 50,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            alignment: Alignment.center,
            width: 138,
            height: 50,
            child: BlocBuilder<ThemeModeCubit, ThemeMode>(builder: (c, v) {
              return Row(
                children: [
                  Container(
                    child: ToggleSwitch(
                      onChanged: (v) {
                        context.read<ThemeModeCubit>().toggle();
                      },
                      content: v == ThemeMode.dark
                          ? Icon(FluentIcons.clear_night)
                          : Icon(Icons.sunny),
                      checked: v == ThemeMode.dark,
                    ),
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  Container(
                      width: 32,
                      child: FlyoutTarget(
                          controller: menuController,
                          child: IconButton(
                            icon: Icon(FluentIcons.translate),
                            onPressed: () {
                              menuController.showFlyout(
                                  autoModeConfiguration:
                                      FlyoutAutoConfiguration(
                                    preferredMode:
                                        FlyoutPlacementMode.topCenter,
                                  ),
                                  barrierDismissible: true,
                                  dismissOnPointerMoveAway: false,
                                  dismissWithEsc: true,
                                  builder: (context) {
                                    return MenuFlyout(
                                      items: [
                                          {
                                            "label": "English",
                                            "value": "en_US",
                                          },
                                          {
                                            "label": "中文",
                                            "value": "zh_CN",
                                          },
                                          {
                                            "label": "日本語",
                                            "value": "ja_JP",
                                          },
                                        ].map((el) {
                                          return MenuFlyoutItem(
                                            text: Text(el["label"] ?? "-"),
                                            selected:
                                                context.locale == el["value"],
                                            onPressed: () {
                                              var locals =
                                                  el["value"]?.split("_") ?? [];
                                              context.setLocale(
                                                  Locale(locals[0], locals[1]));
                                              Navigator.of(context).pop();
                                            },
                                          );
                                        }).toList(),
                                    );
                                  }
                                  // navigatorKey: rootNavigatorKey.currentState,
                                  );
                            },
                          )))
                ],
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
                  await windowManager.hide();
                } catch (e) {}
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
    );
  }
}
