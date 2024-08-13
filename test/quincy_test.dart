import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:quincy_sui/utils/quincy.dart';

void main() {
  group('Test start, Quincy runtime', () {
    test('Empty configPath should be failed', () async {
      var quincy = await Quincy.createInstance(configPath: "");
      expect(quincy.status, QuincyRuntimeStatus.failed);
    });

    test('Wrong configPath should be failed', () async {
      var quincy = await Quincy.createInstance(configPath: "notExists/asd");
      expect(quincy.status, QuincyRuntimeStatus.failed);
    });

    test('Right configPath should be normally started', () async {
      var quincy = await Quincy.createInstance(configPath: join( "C:","Users","qq651","Documents","quincy_conf_dir","quincy_conf_d7683320b35f02e06dd7055afd0dbd61b9e8528c.toml"));

      expect(quincy.status, QuincyRuntimeStatus.active);
    });

    test("Stoping with right configPath should be stopped", () async {
      var quincy = await Quincy.createInstance(configPath: join( "C:","Users","qq651","Documents","quincy_conf_dir","quincy_conf_d7683320b35f02e06dd7055afd0dbd61b9e8528c.toml"));
      quincy.stop();
      expect(quincy.status, QuincyRuntimeStatus.stoped);
    });

    test("Logs should be equal or greater than 1", () async {
      var quincy = await Quincy.createInstance(configPath: join( "C:","Users","qq651","Documents","quincy_conf_dir","quincy_conf_d7683320b35f02e06dd7055afd0dbd61b9e8528c.toml"));
      await Future.delayed(Duration(seconds: 3));
      expect([...quincy.logs, quincy.errorLogs].isNotEmpty, true);
    });
  });
}