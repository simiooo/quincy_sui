import 'package:fluent_ui/fluent_ui.dart';

class Top extends StatelessWidget {
  const Top({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Expanded(
              child: Container(
            child: CommandBar(primaryItems: [
              CommandBarBuilderItem(
                  builder: (context, mode, w) => Tooltip(
                        message: "Delete what is currently selected!",
                        child: w,
                      ),
                  wrappedItem: CommandBarButton(
                    icon: const Icon(FluentIcons.add),
                    label: const Text('新增'),
                    onPressed: () {},
                  ))
            ]),
          )),
          Flexible(
              flex: 0,
              child: Container(
                child: CommandBar(
                    overflowBehavior: CommandBarOverflowBehavior.noWrap,
                    primaryItems: [
                      CommandBarBuilderItem(
                          builder: (context, mode, w) => Tooltip(
                                message: "Minimize window!",
                                child: w,
                              ),
                          wrappedItem: CommandBarButton(
                            icon: const Icon(FluentIcons.chrome_minimize),
                            onPressed: () {},
                          )),
                      CommandBarBuilderItem(
                          builder: (context, mode, w) => Tooltip(
                                message: "Maximize window!",
                                child: w,
                              ),
                          wrappedItem: CommandBarButton(
                            icon: const Icon(FluentIcons.square_shape),
                            onPressed: () {},
                          )),
                      CommandBarBuilderItem(
                          builder: (context, mode, w) => Tooltip(
                                message: "Close window!",
                                child: w,
                              ),
                          wrappedItem: CommandBarButton(
                            icon: const Icon(FluentIcons.cancel),
                            onPressed: () {},
                          )),
                    ]),
              ))
        ],
      ),
    );
  }
}
