import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:pure_live/common/services/settings/app_settings_controller.dart';
import 'package:pure_live/common/services/settings/danmaku_settings_controller.dart';
import 'package:pure_live/common/services/settings/font_settings_controller.dart';
import 'package:pure_live/common/services/settings/player_settings_controller.dart';
import 'package:pure_live/common/services/settings/volume_settings_controller.dart';
import 'package:pure_live/common/services/settings/window_size_controller.dart';
import 'package:pure_live/common/services/settings_service.dart';
import 'package:pure_live/common/utils/hive_pref_util.dart';
import 'package:pure_live/get/get.dart';
import 'package:pure_live/modules/settings/pages/video_settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory hiveDirectory;
  late Map<String, dynamic> english;
  late Map<String, dynamic> chinese;

  setUpAll(() async {
    hiveDirectory = await Directory.systemTemp.createTemp('pure-live-loudness-settings-');
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    english = jsonDecode(await File('assets/translations/en.json').readAsString()) as Map<String, dynamic>;
    chinese = jsonDecode(await File('assets/translations/zh.json').readAsString()) as Map<String, dynamic>;
    Hive.init(hiveDirectory.path);
    await HivePrefUtil.init();
  });

  setUp(() async {
    Get.testMode = true;
    Get.reset();
    await HivePrefUtil.clear();
    Get.put<SettingsService>(_TestSettingsService());
  });

  tearDown(() {
    Get.reset();
    Get.testMode = false;
  });

  tearDownAll(() async {
    await Hive.close();
    await hiveDirectory.delete(recursive: true);
  });

  for (final language in ['en', 'zh']) {
    testWidgets('loudness modes remain usable at large text scale in $language', (tester) async {
      final translations = language == 'en' ? english : chinese;
      final title = translations['loudness_compensation'] as String;
      final strong = translations['loudness_compensation_strong'] as String;
      final settings = SettingsService.to.player;
      await _pumpSettings(tester, language, translations);

      final tile = find.ancestor(of: find.text(title), matching: find.byType(ListTile));
      await tester.scrollUntilVisible(tile, 120, scrollable: _pageScrollable());
      await tester.pumpAndSettle();
      expect(tester.widget<ListTile>(tile).onTap, isNotNull);
      await tester.tap(tile);
      await tester.pumpAndSettle();

      final dialog = find.byKey(const ValueKey('loudness-compensation-dialog'));
      expect(dialog, findsOneWidget);
      expect(find.text(translations['loudness_compensation_description'] as String), findsNWidgets(2));
      expect(find.text(translations['loudness_compensation_detail'] as String), findsOneWidget);
      for (final mode in ['off', 'gentle', 'standard', 'strong']) {
        expect(
          find.descendant(of: dialog, matching: find.text(translations['loudness_compensation_$mode'] as String)),
          findsOneWidget,
        );
      }
      expect(tester.getRect(dialog).top, greaterThanOrEqualTo(0));
      expect(tester.getRect(dialog).bottom, lessThanOrEqualTo(480));
      final choice = find.widgetWithText(SimpleDialogOption, strong);
      await tester.ensureVisible(choice);
      await tester.pumpAndSettle();
      await tester.tap(choice);
      await tester.pumpAndSettle();
      expect(settings.loudnessCompensationMode.value, 'strong');
      expect(find.byKey(const ValueKey('loudness-compensation-dialog')), findsNothing);
      expect(tester.takeException(), isNull);
    }, skip: !Platform.isWindows);
  }

  testWidgets('engine changes disable and restore the selector without changing its saved mode', (tester) async {
    final settings = SettingsService.to.player;
    settings.changeLoudnessCompensationMode('standard');
    await _pumpSettings(tester, 'en', english);
    final tile = find.ancestor(of: find.text('Manual Loudness Boost'), matching: find.byType(ListTile));
    await tester.scrollUntilVisible(tile, 120, scrollable: _pageScrollable());
    await tester.pumpAndSettle();
    expect(tester.widget<ListTile>(tile).onTap, isNotNull);

    settings.videoPlayerKey.value = 'ijk';
    await tester.pumpAndSettle();
    expect(tester.widget<ListTile>(tile).onTap, isNull);
    expect(find.text('Available with the MPV player only'), findsOneWidget);
    expect(settings.loudnessCompensationMode.value, 'standard');

    settings.videoPlayerKey.value = 'mpv';
    await tester.pumpAndSettle();
    expect(tester.widget<ListTile>(tile).onTap, isNotNull);
    expect(find.text('Standard (+6 dB)'), findsOneWidget);
    expect(tester.takeException(), isNull);
  }, skip: !Platform.isWindows);
}

Future<void> _pumpSettings(WidgetTester tester, String language, Map<String, dynamic> translations) async {
  tester.view.physicalSize = const Size(320, 480);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
  await tester.pumpWidget(
    EasyLocalization(
      supportedLocales: [Locale(language)],
      startLocale: Locale(language),
      fallbackLocale: Locale(language),
      saveLocale: false,
      path: 'assets/translations',
      assetLoader: _Translations(translations),
      child: Builder(
        builder: (context) => GetMaterialApp(
          locale: context.locale,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(3)),
            child: child!,
          ),
          home: const VideoSettingsPage(platformOverride: TargetPlatform.windows),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Finder _pageScrollable() => find.descendant(of: find.byType(ListView), matching: find.byType(Scrollable)).first;

class _Translations extends AssetLoader {
  const _Translations(this.translations);

  final Map<String, dynamic> translations;

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async => translations;
}

class _TestSettingsService extends SettingsService {
  final AppSettingsController _app = AppSettingsController();
  final DanmakuSettingsController _danmaku = DanmakuSettingsController();
  final FontSettingsController _font = FontSettingsController();
  final PlayerSettingsController _player = PlayerSettingsController();
  final VolumeSettingsController _volume = VolumeSettingsController();
  final WindowSizeController _window = WindowSizeController();

  @override
  AppSettingsController get app => _app;
  @override
  DanmakuSettingsController get danmaku => _danmaku;
  @override
  FontSettingsController get font => _font;
  @override
  PlayerSettingsController get player => _player;
  @override
  VolumeSettingsController get vol => _volume;
  @override
  WindowSizeController get window => _window;
  @override
  // Test fixture intentionally skips production controller registrations.
  // ignore: must_call_super
  void onInit() {}
}
