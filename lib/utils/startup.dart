import 'package:hive_flutter/hive_flutter.dart';
import 'package:launch_at_startup/launch_at_startup.dart';

void initialStartup() async {
  await Hive.initFlutter();
  var settingDB = await Hive.openBox('settingDB');
  var isLaunchAtStartup = settingDB.get("isLaunchAtStartup") as bool?;
 
  if (isLaunchAtStartup != null && isLaunchAtStartup) {
    await launchAtStartup.enable();
  } else {
    await launchAtStartup.disable();
  }
}
