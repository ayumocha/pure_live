import 'package:flutter/foundation.dart';
import 'package:pure_live/common/index.dart';
import 'package:pure_live/common/consts/app_consts.dart';
import 'package:pure_live/player/utils/player_consts.dart';
import 'package:pure_live/player/core/portrait_stream_support.dart';

@visibleForTesting
String defaultVideoPlayerKeyForPlatform(TargetPlatform platform) => platform == TargetPlatform.iOS ? 'ijk' : 'mpv';

String get _defaultVideoPlayerKey => defaultVideoPlayerKeyForPlatform(defaultTargetPlatform);

class PlayerSettingsController extends GetxController {
  static PlayerSettingsController get to => Get.find<PlayerSettingsController>();

  final RxInt videoFitIndex = hiveInt('videoFitIndex', 0);

  final RxString videoPlayerKey = hiveString('videoPlayerKey', _defaultVideoPlayerKey);

  final RxString preferResolution = hiveString('preferResolution', PlayerConsts.resolutions.first);

  final RxString preferResolutionCellular = hiveString('preferResolutionCellular', PlayerConsts.resolutions.first);

  final RxBool enableCodec = hiveBool('enableCodec', true);

  final RxBool playerCompatMode = hiveBool('playerCompatMode', false);

  final RxBool customPlayerOutput = hiveBool('customPlayerOutput', false);

  final RxString videoOutputDriver = hiveString('videoOutputDriver', 'gpu');

  final RxString audioOutputDriver = hiveString('audioOutputDriver', 'auto');

  final RxString videoHardwareDecoder = hiveString('videoHardwareDecoder', 'auto');

  final RxBool floatPlay = hiveBool('floatPlay', false);

  final RxBool windowsPipAlwaysOnTop = hiveBool('windowsPipAlwaysOnTop', false);

  final RxBool enableRtxVsr = hiveBool('enableRtxVsr', false);

  final RxBool audioOnly = false.obs;

  final RxBool useHardStopOnExit = hiveBool('useHardStopOnExit', false);

  /// 竖屏直播安全默认（测试即契约：旧备份迁移时补齐以下字段）：
  /// 竖屏流自适应默认开启、自适应高度、全屏策略跟随源方向、PiP 跟随源方向。
  final RxBool enablePortraitStreamAdaptation = hiveBool('enablePortraitStreamAdaptation', true);

  final RxBool portraitAdaptiveHeight = hiveBool('portraitAdaptiveHeight', true);

  final RxString portraitFullscreenPolicy = hiveString('portraitFullscreenPolicy', 'followSource');

  final RxBool portraitPipFollowSource = hiveBool('portraitPipFollowSource', true);

  /// 房间级竖屏策略覆盖：随备份导出/导入持久化（本工具链没有 hive map 基元）。
  final RxMap<String, String> portraitRoomOverrides = <String, String>{}.obs;

  String get safePortraitFullscreenPolicy {
    const allowed = {'followSource', 'auto', 'manual'};
    final value = portraitFullscreenPolicy.v;
    return allowed.contains(value) ? value : 'followSource';
  }

  // ---------------------------------------------------------------------------
  // Portrait live settings
  // ---------------------------------------------------------------------------

  final RxString portraitLayoutModeName = hiveString('portraitLayoutMode', PortraitLayoutMode.balanced.name);

  PortraitLayoutMode get portraitLayoutMode =>
      _enumByName(PortraitLayoutMode.values, portraitLayoutModeName.v, PortraitLayoutMode.balanced);

  void changePortraitLayoutMode(PortraitLayoutMode mode) {
    portraitLayoutModeName.v = mode.name;
  }

  void resetPortraitLayoutMode() {
    portraitLayoutModeName.v = PortraitLayoutMode.balanced.name;
  }

  final RxString portraitDanmakuModeName = hiveString('portraitDanmakuMode', PortraitDanmakuMode.followGlobal.name);

  PortraitDanmakuMode get portraitDanmakuMode =>
      _enumByName(PortraitDanmakuMode.values, portraitDanmakuModeName.v, PortraitDanmakuMode.followGlobal);

  void changePortraitDanmakuMode(PortraitDanmakuMode mode) {
    portraitDanmakuModeName.v = mode.name;
  }

  void resetPortraitDanmakuMode() {
    portraitDanmakuModeName.v = PortraitDanmakuMode.followGlobal.name;
  }

  final RxString portraitVideoHeightModeName = hiveString(
    'portraitVideoHeightMode',
    PortraitVideoHeightMode.adaptive.name,
  );

  PortraitVideoHeightMode get portraitVideoHeightMode =>
      _enumByName(PortraitVideoHeightMode.values, portraitVideoHeightModeName.v, PortraitVideoHeightMode.adaptive);

  void changePortraitVideoHeightMode(PortraitVideoHeightMode mode) {
    portraitVideoHeightModeName.v = mode.name;
  }

  final RxDouble portraitCustomHeight = hiveDouble('portraitCustomHeight', 0.0);

  void changePortraitCustomHeight(double height) {
    portraitCustomHeight.v = height.clamp(0.0, double.infinity);
  }

  void resetPortraitVideoHeight() {
    portraitVideoHeightModeName.v = PortraitVideoHeightMode.adaptive.name;
    portraitCustomHeight.v = 0.0;
  }

  // ---------------------------------------------------------------------------
  // Video fit
  // ---------------------------------------------------------------------------

  List<BoxFit> get videoFitArray => AppConsts().videoFitType.map((e) => e['attr'] as BoxFit).toList();

  // ---------------------------------------------------------------------------
  // Resolution
  // ---------------------------------------------------------------------------

  void changePreferResolution(String resolution) {
    if (PlayerConsts.resolutions.contains(resolution)) {
      preferResolution.v = resolution;
    }
  }

  void changePreferResolutionCellular(String resolution) {
    if (PlayerConsts.resolutions.contains(resolution)) {
      preferResolutionCellular.v = resolution;
    }
  }

  // ---------------------------------------------------------------------------
  // Reset
  // ---------------------------------------------------------------------------

  void resetMpvPlayerSettings() {
    enableCodec.v = true;
    playerCompatMode.v = false;
    customPlayerOutput.v = false;
    videoOutputDriver.v = 'gpu';
    audioOutputDriver.v = 'auto';
    videoHardwareDecoder.v = 'auto';
    enableRtxVsr.v = false;
    preferResolution.v = PlayerConsts.resolutions.first;
    preferResolutionCellular.v = PlayerConsts.resolutions.first;
    useHardStopOnExit.v = false;
  }

  // ---------------------------------------------------------------------------
  // Export
  // ---------------------------------------------------------------------------

  Map<String, dynamic> toJson() {
    return {
      'videoFitIndex': videoFitIndex.v,
      'videoPlayerKey': videoPlayerKey.v,
      'preferResolution': preferResolution.v,
      'preferResolutionCellular': preferResolutionCellular.v,
      'enableCodec': enableCodec.v,
      'playerCompatMode': playerCompatMode.v,
      'customPlayerOutput': customPlayerOutput.v,
      'videoOutputDriver': videoOutputDriver.v,
      'audioOutputDriver': audioOutputDriver.v,
      'videoHardwareDecoder': videoHardwareDecoder.v,
      'floatPlay': floatPlay.v,
      'windowsPipAlwaysOnTop': windowsPipAlwaysOnTop.v,
      'enableRtxVsr': enableRtxVsr.v,
      'audioOnly': false,
      'useHardStopOnExit': useHardStopOnExit.v,
      'portraitLayoutMode': portraitLayoutMode.name,
      'portraitDanmakuMode': portraitDanmakuMode.name,
      'portraitVideoHeightMode': portraitVideoHeightMode.name,
      'portraitCustomHeight': portraitCustomHeight.v,
      'enablePortraitStreamAdaptation': enablePortraitStreamAdaptation.v,
      'portraitAdaptiveHeight': portraitAdaptiveHeight.v,
      'portraitFullscreenPolicy': safePortraitFullscreenPolicy,
      'portraitPipFollowSource': portraitPipFollowSource.v,
      'portraitRoomOverrides': Map<String, String>.from(portraitRoomOverrides),
    };
  }

  // ---------------------------------------------------------------------------
  // Import
  // ---------------------------------------------------------------------------

  void fromJson(Map<String, dynamic> json) {
    videoFitIndex.v = json['videoFitIndex'] ?? 0;

    videoPlayerKey.v = json['videoPlayerKey'] ?? _defaultVideoPlayerKey;

    preferResolution.v = json['preferResolution'] ?? PlayerConsts.resolutions.first;

    preferResolutionCellular.v = json['preferResolutionCellular'] ?? PlayerConsts.resolutions.first;

    enableCodec.v = json['enableCodec'] ?? true;

    playerCompatMode.v = json['playerCompatMode'] ?? false;

    customPlayerOutput.v = json['customPlayerOutput'] ?? false;

    videoOutputDriver.v = json['videoOutputDriver'] ?? 'gpu';

    audioOutputDriver.v = json['audioOutputDriver'] ?? 'auto';

    videoHardwareDecoder.v = json['videoHardwareDecoder'] ?? 'auto';

    floatPlay.v = json['floatPlay'] ?? false;

    windowsPipAlwaysOnTop.v = json['windowsPipAlwaysOnTop'] ?? false;

    enableRtxVsr.v = json['enableRtxVsr'] ?? false;

    audioOnly.v = false;

    useHardStopOnExit.v = json['useHardStopOnExit'] ?? false;

    portraitLayoutModeName.v = _enumName(
      PortraitLayoutMode.values,
      json['portraitLayoutMode'],
      PortraitLayoutMode.balanced,
    );

    portraitDanmakuModeName.v = _enumName(
      PortraitDanmakuMode.values,
      json['portraitDanmakuMode'],
      PortraitDanmakuMode.followGlobal,
    );

    portraitVideoHeightModeName.v = _enumName(
      PortraitVideoHeightMode.values,
      json['portraitVideoHeightMode'],
      PortraitVideoHeightMode.adaptive,
    );

    portraitCustomHeight.v = (json['portraitCustomHeight'] as num?)?.toDouble() ?? 0.0;

    enablePortraitStreamAdaptation.v = json['enablePortraitStreamAdaptation'] ?? true;

    portraitAdaptiveHeight.v = json['portraitAdaptiveHeight'] ?? true;

    portraitFullscreenPolicy.v = normalizePortraitFullscreenPolicy(json['portraitFullscreenPolicy']);

    portraitPipFollowSource.v = json['portraitPipFollowSource'] ?? true;

    final overrides = json['portraitRoomOverrides'];
    portraitRoomOverrides
      ..clear()
      ..addAll(
        overrides is Map
            ? overrides.map((key, value) => MapEntry(key.toString(), value.toString()))
            : const <String, String>{},
      );
  }

  // ---------------------------------------------------------------------------
  // Config extraction
  // ---------------------------------------------------------------------------

  static Map<String, dynamic> extractConfig(Map<String, dynamic>? rootConfig) {
    final player = rootConfig?['player'] as Map<String, dynamic>? ?? {};

    return {
      'videoFitIndex': player['videoFitIndex'] ?? 0,

      'videoPlayerKey': player['videoPlayerKey'] ?? _defaultVideoPlayerKey,

      'preferResolution': player['preferResolution'] ?? PlayerConsts.resolutions.first,

      'preferResolutionCellular': player['preferResolutionCellular'] ?? PlayerConsts.resolutions.first,

      'enableCodec': player['enableCodec'] ?? true,

      'playerCompatMode': player['playerCompatMode'] ?? false,

      'customPlayerOutput': player['customPlayerOutput'] ?? false,

      'videoOutputDriver': player['videoOutputDriver'] ?? 'gpu',

      'audioOutputDriver': player['audioOutputDriver'] ?? 'auto',

      'videoHardwareDecoder': player['videoHardwareDecoder'] ?? 'auto',

      'floatPlay': player['floatPlay'] ?? false,

      'windowsPipAlwaysOnTop': player['windowsPipAlwaysOnTop'] ?? false,

      'rememberPipPosition': player['rememberPipPosition'] ?? true,

      'enableRtxVsr': player['enableRtxVsr'] ?? false,

      'audioOnly': false,

      'useHardStopOnExit': player['useHardStopOnExit'] ?? false,

      'portraitLayoutMode': _enumName(
        PortraitLayoutMode.values,
        player['portraitLayoutMode'],
        PortraitLayoutMode.balanced,
      ),

      'portraitDanmakuMode': _enumName(
        PortraitDanmakuMode.values,
        player['portraitDanmakuMode'],
        PortraitDanmakuMode.followGlobal,
      ),

      'portraitVideoHeightMode': _enumName(
        PortraitVideoHeightMode.values,
        player['portraitVideoHeightMode'],
        PortraitVideoHeightMode.adaptive,
      ),

      'portraitCustomHeight': (player['portraitCustomHeight'] as num?)?.toDouble() ?? 0.0,

      'enablePortraitStreamAdaptation': player['enablePortraitStreamAdaptation'] ?? true,

      'portraitAdaptiveHeight': player['portraitAdaptiveHeight'] ?? true,

      'portraitFullscreenPolicy': normalizePortraitFullscreenPolicy(player['portraitFullscreenPolicy']),

      'portraitPipFollowSource': player['portraitPipFollowSource'] ?? true,

      'portraitRoomOverrides':
          player['portraitRoomOverrides'] is Map ? Map<String, String>.from(player['portraitRoomOverrides'] as Map) : <String, String>{},
    };
  }

  /// 备份迁移的竖屏全屏策略归一化：非法枚举值一律回到安全的 followSource。
  @visibleForTesting
  static String normalizePortraitFullscreenPolicy(dynamic raw) {
    const allowed = {'followSource', 'auto', 'manual'};
    return allowed.contains(raw?.toString()) ? raw.toString() : 'followSource';
  }

  // ---------------------------------------------------------------------------
  // Config merge
  // ---------------------------------------------------------------------------

  static Map<String, dynamic> mergeConfig(Map<String, dynamic> rootConfig, Map<String, dynamic> updateFields) {
    final player = Map<String, dynamic>.from(rootConfig['player'] ?? {});

    updateFields.forEach((key, value) {
      player[key] = value;
    });

    rootConfig['player'] = player;

    return rootConfig;
  }

  // ---------------------------------------------------------------------------
  // Enum helpers
  // ---------------------------------------------------------------------------

  static T _enumByName<T extends Enum>(List<T> values, dynamic raw, T fallback) {
    final name = raw?.toString();

    for (final value in values) {
      if (value.name == name) {
        return value;
      }
    }

    return fallback;
  }

  static String _enumName<T extends Enum>(List<T> values, dynamic raw, T fallback) {
    return _enumByName(values, raw, fallback).name;
  }
}
