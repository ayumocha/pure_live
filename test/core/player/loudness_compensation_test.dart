import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:media_core/media_core.dart';
import 'package:pure_live/core/config/player_settings_controller.dart';
import 'package:pure_live/core/player/kernel/loudness_compensation.dart';
import 'package:pure_live/core/storage/hive_pref_util.dart';
import 'package:pure_live/core/storage/hive_rx.dart';

/// Bounded wait for an unawaited Hive write to land.
Future<void> _waitFor(bool Function() predicate, {Duration timeout = const Duration(seconds: 5)}) async {
  final deadline = DateTime.now().add(timeout);

  while (DateTime.now().isBefore(deadline)) {
    if (predicate()) return;
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }

  throw StateError('condition not met within $timeout');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Hive.openBox<dynamic>('app_settings', bytes: Uint8List(0));
    await HivePrefUtil.init();
  });

  tearDownAll(() async {
    await Hive.close();
  });

  setUp(() {
    LoudnessCompensation.lastError.value = null;
  });

  group('响度档位', () {
    test('已知档位按名字还原', () {
      for (final mode in LoudnessCompensationMode.values) {
        expect(normalizeLoudnessCompensationMode(mode.name), mode);
      }
    });

    test('缺失、空值与陌生值一律回落到关闭——旧安装升级不该被改音量', () {
      for (final raw in <String>['', ' ', 'loud', 'STRONG', 'gentle ']) {
        expect(normalizeLoudnessCompensationMode(raw), LoudnessCompensationMode.off);
      }
    });

    test('增益表：关闭写 0 dB，这是「关掉就还原」的实现方式', () {
      expect(loudnessCompensationGainDb(LoudnessCompensationMode.off), 0);
      expect(loudnessCompensationGainDb(LoudnessCompensationMode.gentle), 3);
      expect(loudnessCompensationGainDb(LoudnessCompensationMode.standard), 6);
      expect(loudnessCompensationGainDb(LoudnessCompensationMode.strong), 9);
    });
  });

  group('引擎属性与选项', () {
    test('只写 volume-gain，值是纯数字字符串', () {
      expect(loudnessCompensationProperties(LoudnessCompensationMode.standard), {'volume-gain': '6'});

      final option = loudnessCompensationOption(LoudnessCompensationMode.gentle);
      expect(option.key, 'volume-gain');
      expect(option.value, '3');
      expect(loudnessCompensationProperty, 'volume-gain');
    });

    test('关闭档也给出显式 0，运行中切回关闭才能立刻还原', () {
      final option = loudnessCompensationOption(LoudnessCompensationMode.off);
      expect(option.value, '0');
    });
  });

  group('拒绝处置', () {
    test('内核报 unsupported 时给出可见失败，而不是当作已生效', () {
      final report = EngineOptionReport(
        unsupported: <EngineOption>[loudnessCompensationOption(LoudnessCompensationMode.standard)],
      );

      expect(loudnessCompensationFailure(report, LoudnessCompensationMode.standard), contains('volume-gain=6'));
    });

    test('落到下一次 open 也算接受（不因此重建引擎）', () {
      final report = EngineOptionReport(
        stagedForNextOpen: <EngineOption>[loudnessCompensationOption(LoudnessCompensationMode.strong)],
      );

      expect(loudnessCompensationFailure(report, LoudnessCompensationMode.strong), isNull);
    });

    test('别的属性被拒不算这次写失败', () {
      final report = EngineOptionReport(unsupported: const <EngineOption>[EngineOption('hwdec', 'no')]);

      expect(loudnessCompensationFailure(report, LoudnessCompensationMode.gentle), isNull);
    });

    test('成功写入不留下错误状态', () {
      final report = EngineOptionReport(
        appliedLive: <EngineOption>[loudnessCompensationOption(LoudnessCompensationMode.gentle)],
      );

      expect(loudnessCompensationFailure(report, LoudnessCompensationMode.gentle), isNull);
      expect(LoudnessCompensation.lastError.value, isNull);
    });
  });

  group('文案键', () {
    test('每个档位都有独立的名称与说明键', () {
      final labels = <String>{};
      final descriptions = <String>{};

      for (final mode in LoudnessCompensationMode.values) {
        labels.add(loudnessCompensationLabelKey(mode));
        descriptions.add(loudnessCompensationDescriptionKey(mode));
      }

      expect(labels.length, LoudnessCompensationMode.values.length);
      expect(descriptions.length, LoudnessCompensationMode.values.length);
      expect(loudnessCompensationLabelKey(LoudnessCompensationMode.standard), 'loudness_compensation_mode_standard');
      expect(
        loudnessCompensationDescriptionKey(LoudnessCompensationMode.standard),
        'loudness_compensation_mode_standard_desc',
      );
    });
  });

  group('设置持久化', () {
    const key = 'loudnessCompensation';

    setUp(() async {
      // 关键：清掉这个键，而不是写空串。缺失键才是旧安装升级时的真实状态。
      await HivePrefUtil.remove(key);
    });

    test('没有存过就是关闭——旧安装升级不会被动改音量', () async {
      expect(HivePrefUtil.getString(key), isNull);
      expect(normalizeLoudnessCompensationMode(HivePrefUtil.getString(key) ?? ''), LoudnessCompensationMode.off);
    });

    test('写入后新实例读到同一个档位', () async {
      final settings = PlayerSettingsController();
      expect(settings.loudnessCompensation.v, LoudnessCompensationMode.off.name);

      settings.loudnessCompensation.v = LoudnessCompensationMode.strong.name;

      // `hive()` 是 unawaited 落盘，等它真正写完再换一个实例读。
      await _waitFor(() => HivePrefUtil.getString(key) == LoudnessCompensationMode.strong.name);

      expect(PlayerSettingsController().loudnessCompensation.v, LoudnessCompensationMode.strong.name);
    });
  });
}
