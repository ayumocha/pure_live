// Opt-in live check of the Douyu play-URL path: runs the same signing request
// the app makes for a room and prints the server's answer, so a failure can be
// attributed to the API, the signature or the session instead of guessed at.
//
//   PURELIVE_DOUYU_PROBE=1 DY_ROOM=9999 flutter test tool/probes/douyu_play_url_probe_test.dart
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:pure_live/core/config/settings_service.dart';
import 'package:pure_live/core/storage/hive_pref_util.dart';
import 'package:pure_live/shared/platforms/douyu/douyu_site.dart';
import 'package:pure_live/core/models/live_play_quality.dart';
import 'package:pure_live/core/models/live_room.dart';
import 'package:pure_live/shared/platforms/live_quality_discovery.dart';
import 'package:pure_live/shared/platforms/live_site.dart';
import 'package:pure_live/get/get.dart';

void main() {
  final enabled = Platform.environment['PURELIVE_DOUYU_PROBE'] == '1';
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final temp = await Directory.systemTemp.createTemp('douyu-probe-');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async => temp.path,
    );
    await Hive.openBox<dynamic>('app_settings', bytes: Uint8List(0));
    await HivePrefUtil.init();
    Get.put(SettingsService(), permanent: true);
  });

  tearDownAll(() async {
    await Hive.close();
  });

  test(
    'Douyu play URL resolves with the shipped signing code',
    () async {
      final room = Platform.environment['DY_ROOM'] ?? '9999';
      final site = DouyuSite();

      final detail = await site.getRoomDetail(LiveRoom(roomId: room, platform: 'douyu'));
      // ignore: avoid_print
      print('[probe] detail: live=${detail.liveStatus} title=${detail.title}');

      final qualities = await site.getPlayQualites(liveroom: detail);
      // ignore: avoid_print
      print('[probe] qualities: ${qualities.map((q) => '${q.quality}').join(', ')}');

      final urls = await site.getPlayUrls(
        liveroom: detail,
        quality: qualities.isEmpty ? LivePlayQuality(quality: '原画', sort: 0) : qualities.first,
      );
      // ignore: avoid_print
      print('[probe] play url: ${urls.isEmpty ? '<empty>' : urls.first}');
      expect(urls, isNotEmpty);
    },
    skip: !enabled,
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
