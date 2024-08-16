import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:hive/hive.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:quincy_sui/utils/common_path.dart';
import 'package:quincy_sui/utils/file_manager_opener.dart';

class Setting extends StatefulWidget {
  const Setting({Key? key}) : super(key: key);

  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  final _formKey = GlobalKey<FormBuilderState>();
  Box<dynamic>? settingStop;
  Map<String, dynamic> initForm = {};
  initBox() async {
    settingStop = await Hive.openBox<dynamic>("settingDB");
    if (settingStop == null) {
      return;
    }
    initForm = settingStop!.toMap().map((key, value) {
      return MapEntry(key.toString(), value);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initBox();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(144, 12, 40, 16),
      alignment: Alignment.centerLeft,
      width: MediaQuery.sizeOf(context).width,
      height: MediaQuery.sizeOf(context).height,
      child: FormBuilder(
          key: _formKey,
          initialValue: initForm,
          onChanged: () async {
            if (_formKey.currentState == null || settingStop == null) {
              return;
            }
            _formKey.currentState!.save();
            var payload = _formKey.currentState!.value;
            settingStop!.put("isLaunchAtStartup", payload["laundchAtStartup"]);
            if (payload["laundchAtStartup"] != null &&
                payload["laundchAtStartup"]) {
              await launchAtStartup.enable();
            } else {
              await launchAtStartup.disable();
            }
            print(await launchAtStartup.isEnabled());
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InfoLabel(
                label: "Launch at startup:",
                child: FormBuilderField<bool>(
                    builder: (field) {
                      return ToggleSwitch(
                        checked: field.value ?? false,
                        onChanged: (bool value) {
                          field.didChange(value);
                        },
                      );
                    },
                    name: "laundchAtStartup"),
              ),
              SizedBox(height: 24),
              InfoLabel(
                label: "Check Configuration files in system file manager:",
                child: Button(
                  onPressed: () async {
                    fileMangerOpen((await CommonPath.confDir).path);
                  },
                  child: Text("Open File Manager"),
                ),
              ),
            ],
          )),
    );
  }
}
