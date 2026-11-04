import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pure_live/core/network/douyu_diagnose.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(DouyuDiagnose.clear);

  test('记录阶段与键值，并保留时间戳', () {
    DouyuDiagnose.record('encryption', <String, Object?>{'did': 'abc', 'native': true});

    expect(DouyuDiagnose.events, hasLength(1));
    expect(DouyuDiagnose.events.single, contains('encryption'));
    expect(DouyuDiagnose.events.single, contains('did=abc'));
    expect(DouyuDiagnose.events.single, contains('native=true'));
  });

  test('空值不写进记录，避免噪声', () {
    DouyuDiagnose.record('stage', <String, Object?>{'empty': null, 'blank': '   '});

    expect(DouyuDiagnose.events.single.trim(), endsWith('stage'));
  });

  test('超长响应体被截断', () {
    DouyuDiagnose.record('play-request-failed', <String, Object?>{'body': 'x' * 500});

    expect(DouyuDiagnose.events.single.length, lessThan(320));
    expect(DouyuDiagnose.events.single, contains('…'));
  });

  test('环形缓冲只保留最近的事件', () {
    for (var i = 0; i < 60; i++) {
      DouyuDiagnose.record('e$i');
    }

    expect(DouyuDiagnose.events, hasLength(40));
    expect(DouyuDiagnose.events.last, contains('e59'));
    expect(DouyuDiagnose.events.any((line) => line.contains('e0 ')), isFalse);
  });

  test('flushToDisk 写出可直接阅读的文件', () async {
    final directory = await Directory.systemTemp.createTemp('douyu-diagnose-');
    DouyuDiagnose.record('encryption', <String, Object?>{'did': 'abc'});

    final path = await DouyuDiagnose.flushToDisk(directory: directory);

    expect(path, isNotNull);
    final text = await File(path!).readAsString();
    expect(text, contains('PureLive douyu diagnostics'));
    expect(text, contains('did=abc'));

    await directory.delete(recursive: true);
  });
}
