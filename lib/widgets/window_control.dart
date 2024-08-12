import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' hide ButtonStyle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quincy_sui/store/theme.dart';
import 'package:window_manager/window_manager.dart';

class WindowControl extends StatelessWidget {
const WindowControl({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context){
    return Container(
              width: 240,
              height: 50,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.center,
                    width: 100,
                    height: 50,
                    child: BlocBuilder<ThemeModeCubit, ThemeMode>(builder: (c, v) {
                      return Container(
                        child: ToggleSwitch(
                          onChanged: (v) {
                            context.read<ThemeModeCubit>().toggle();
                          },
                          content: v == ThemeMode.dark ? Icon(FluentIcons.clear_night) : Icon(Icons.sunny),
                          checked: v == ThemeMode.dark,
                        ),
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
                        } catch (e) {
                        }
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