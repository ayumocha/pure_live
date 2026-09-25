import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:pure_live/common/services/settings/startup_controller.dart';
import 'package:pure_live/common/utils/hive_pref_util.dart';
import 'package:pure_live/get/get.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory hiveDirectory;

  setUpAll(() async {
    hiveDirectory = await Directory.systemTemp.createTemp('pure-live-startup-settings-');
    Hive.init(hiveDirectory.path);
    await HivePrefUtil.init();
  });

  setUp(() async {
    Get.reset();
    await HivePrefUtil.clear();
  });

  tearDown(() async {
    Get.deleteAll(force: true);
    Get.reset();
    await HivePrefUtil.flush();
  });

  tearDownAll(() async {
    await Hive.close();
    await hiveDirectory.delete(recursive: true);
  });

  test('commits each requested startup state only after native verification', () async {
    await HivePrefUtil.setBool('enableStartUp', false);
    var nativeEnabled = false;
    var enableCalls = 0;
    var disableCalls = 0;
    final controller = StartupController(
      readStartupState: () => nativeEnabled,
      enableStartupAction: () {
        enableCalls++;
        nativeEnabled = true;
        return true;
      },
      disableStartupAction: () {
        disableCalls++;
        nativeEnabled = false;
        return true;
      },
    );

    expect(await controller.setStartupEnabled(true), isTrue);
    expect(controller.enableStartUp.value, isTrue);
    expect(controller.startupStatusKey.value, isEmpty);
    expect(enableCalls, 1);

    expect(await controller.setStartupEnabled(false), isTrue);
    expect(controller.enableStartUp.value, isFalse);
    expect(controller.startupStatusKey.value, isEmpty);
    expect(disableCalls, 1);
    await HivePrefUtil.flush();
    expect(HivePrefUtil.getBool('enableStartUp'), isFalse);
  });

  test('failed or unverifiable native changes roll the switch back to observed state', () async {
    await HivePrefUtil.setBool('enableStartUp', false);
    var nativeEnabled = false;
    final controller = StartupController(
      readStartupState: () => nativeEnabled,
      enableStartupAction: () => false,
      disableStartupAction: () => false,
    );

    expect(await controller.setStartupEnabled(true), isFalse);
    expect(controller.enableStartUp.value, isFalse);
    expect(controller.startupStatusKey.value, 'startup_apply_failed');

    final unverifiable = StartupController(
      readStartupState: () => nativeEnabled,
      enableStartupAction: () => true,
      disableStartupAction: () => true,
    );
    expect(await unverifiable.setStartupEnabled(true), isFalse);
    expect(unverifiable.enableStartUp.value, isFalse);
    expect(unverifiable.startupStatusKey.value, 'startup_apply_failed');
  });

  test('new installation defaults off and startup only reads the native entry', () async {
    var nativeReads = 0;
    var nativeWrites = 0;
    final controller = Get.put(
      StartupController(
        readStartupState: () {
          nativeReads++;
          return false;
        },
        enableStartupAction: () {
          nativeWrites++;
          return true;
        },
        disableStartupAction: () {
          nativeWrites++;
          return true;
        },
      ),
    );

    expect(controller.enableStartUp.value, isFalse);
    expect(await controller.setupLaunchAtStartup(), isTrue);
    expect(nativeReads, 1);
    expect(nativeWrites, 0);
    expect(controller.enableStartUp.value, isFalse);
  });

  test('legacy saved true does not recreate a missing native entry', () async {
    await HivePrefUtil.setBool('enableStartUp', true);
    var nativeWrites = 0;
    final controller = Get.put(
      StartupController(
        readStartupState: () => false,
        enableStartupAction: () {
          nativeWrites++;
          return true;
        },
        disableStartupAction: () {
          nativeWrites++;
          return true;
        },
      ),
    );

    expect(controller.enableStartUp.value, isTrue);
    expect(await controller.setupLaunchAtStartup(), isTrue);
    expect(controller.isApplyingStartup.value, isFalse);
    expect(controller.enableStartUp.value, isFalse);
    expect(nativeWrites, 0);
    await HivePrefUtil.flush();
    expect(HivePrefUtil.getBool('enableStartUp'), isFalse);
  });

  test('existing native entry remains enabled without any startup write', () async {
    await HivePrefUtil.setBool('enableStartUp', false);
    var nativeWrites = 0;
    final controller = Get.put(
      StartupController(
        readStartupState: () => true,
        enableStartupAction: () {
          nativeWrites++;
          return true;
        },
        disableStartupAction: () {
          nativeWrites++;
          return true;
        },
      ),
    );

    expect(await controller.setupLaunchAtStartup(), isTrue);
    expect(controller.enableStartUp.value, isTrue);
    expect(nativeWrites, 0);
    await HivePrefUtil.flush();
    expect(HivePrefUtil.getBool('enableStartUp'), isTrue);
  });

  test('failed startup read leaves saved state intact and never writes', () async {
    await HivePrefUtil.setBool('enableStartUp', true);
    var nativeWrites = 0;
    final controller = Get.put(
      StartupController(
        readStartupState: () => throw StateError('read failed'),
        enableStartupAction: () {
          nativeWrites++;
          return true;
        },
        disableStartupAction: () {
          nativeWrites++;
          return true;
        },
      ),
    );

    expect(await controller.setupLaunchAtStartup(), isFalse);
    expect(controller.enableStartUp.value, isTrue);
    expect(nativeWrites, 0);
  });

  test('backup and direct reactive writes do not authorize native startup', () async {
    var nativeEnabled = false;
    var nativeWrites = 0;
    final controller = Get.put(
      StartupController(
        readStartupState: () => nativeEnabled,
        enableStartupAction: () {
          nativeWrites++;
          nativeEnabled = true;
          return true;
        },
        disableStartupAction: () {
          nativeWrites++;
          nativeEnabled = false;
          return true;
        },
      ),
    );

    expect(await controller.setupLaunchAtStartup(), isTrue);
    controller.fromJson({'enableStartUp': true});
    expect(controller.enableStartUp.value, isFalse);
    expect(nativeWrites, 0);
    await HivePrefUtil.flush();
    expect(HivePrefUtil.getBool('enableStartUp'), isNot(isTrue));

    controller.enableStartUp.value = true;
    expect(nativeWrites, 0);
    expect(nativeEnabled, isFalse);
    await HivePrefUtil.flush();
    expect(HivePrefUtil.getBool('enableStartUp'), isTrue);

    // A direct reactive assignment also cannot authorize startup on relaunch.
    expect(await controller.setupLaunchAtStartup(), isTrue);
    expect(controller.enableStartUp.value, isFalse);
    expect(nativeWrites, 0);
    await HivePrefUtil.flush();
    expect(HivePrefUtil.getBool('enableStartUp'), isFalse);
  });

  test('legacy backup parsing keeps boolean validation and defaults off', () {
    expect(StartupController.parseConfig({})['enableStartUp'], isFalse);
    expect(StartupController.extractConfig(null)['enableStartUp'], isFalse);
    expect(StartupController.extractConfig({'startup': <String, dynamic>{}})['enableStartUp'], isFalse);
    expect(StartupController.parseConfig({'enableStartUp': true})['enableStartUp'], isTrue);
    expect(() => StartupController().fromJson({'enableStartUp': 'bad'}), throwsA(isA<TypeError>()));
  });

  test('explicit toggle writes and commits only the verified native state', () async {
    var nativeEnabled = false;
    var enableCalls = 0;
    final controller = Get.put(
      StartupController(
        readStartupState: () => nativeEnabled,
        enableStartupAction: () {
          enableCalls++;
          nativeEnabled = true;
          return true;
        },
        disableStartupAction: () => false,
      ),
    );

    expect(await controller.setupLaunchAtStartup(), isTrue);
    expect(await controller.toggleStartup(), isTrue);
    expect(enableCalls, 1);
    expect(controller.enableStartUp.value, isTrue);
    controller.fromJson({'enableStartUp': false});
    expect(controller.enableStartUp.value, isTrue);
    expect(enableCalls, 1);
  });

  test('a late startup read cannot overwrite a later explicit request', () async {
    final startupRead = Completer<bool>();
    var nativeEnabled = false;
    var reads = 0;
    var enableCalls = 0;
    final controller = Get.put(
      StartupController(
        readStartupState: () {
          reads++;
          return reads == 1 ? startupRead.future : nativeEnabled;
        },
        enableStartupAction: () {
          enableCalls++;
          nativeEnabled = true;
          return true;
        },
        disableStartupAction: () => false,
      ),
    );

    final startupSync = controller.setupLaunchAtStartup();
    expect(await controller.setStartupEnabled(true), isTrue);
    startupRead.complete(false);
    expect(await startupSync, isFalse);
    expect(enableCalls, 1);
    expect(controller.enableStartUp.value, isTrue);
    expect(controller.startupStatusKey.value, isEmpty);
  });

  test('a startup read finishing after disposal cannot change the saved state', () async {
    final startupRead = Completer<bool>();
    var nativeWrites = 0;
    final controller = Get.put(
      StartupController(
        readStartupState: () => startupRead.future,
        enableStartupAction: () {
          nativeWrites++;
          return true;
        },
        disableStartupAction: () {
          nativeWrites++;
          return true;
        },
      ),
    );

    final startupSync = controller.setupLaunchAtStartup();
    Get.delete<StartupController>(force: true);
    startupRead.complete(true);
    expect(await startupSync, isFalse);
    expect(controller.enableStartUp.value, isFalse);
    expect(nativeWrites, 0);
  });

  test('latest request wins while each caller reports its own requested target', () async {
    await HivePrefUtil.setBool('enableStartUp', false);
    var nativeEnabled = false;
    final requests = <bool>[];
    final gates = <Completer<bool>>[];
    final controller = StartupController(
      readStartupState: () => nativeEnabled,
      enableStartupAction: () async {
        requests.add(true);
        final gate = Completer<bool>();
        gates.add(gate);
        final result = await gate.future;
        if (result) nativeEnabled = true;
        return result;
      },
      disableStartupAction: () async {
        requests.add(false);
        final gate = Completer<bool>();
        gates.add(gate);
        final result = await gate.future;
        if (result) nativeEnabled = false;
        return result;
      },
    );

    final enableResult = controller.setStartupEnabled(true);
    await _waitFor(() => requests.length == 1);
    final disableResult = controller.setStartupEnabled(false);
    gates.first.complete(true);
    await _waitFor(() => requests.length == 2);
    gates.last.complete(true);

    expect(await enableResult, isFalse);
    expect(await disableResult, isTrue);
    expect(requests, [true, false]);
    expect(controller.enableStartUp.value, isFalse);
  });
}

Future<void> _waitFor(bool Function() condition) async {
  for (var attempt = 0; attempt < 100; attempt++) {
    if (condition()) return;
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  fail('Timed out waiting for the startup transaction.');
}
