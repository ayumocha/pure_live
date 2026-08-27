import 'dart:convert';

import 'package:pure_live/common/index.dart';
import 'package:pure_live/model/live_play_quality.dart';
import 'package:pure_live/core/interface/live_site.dart';
import 'package:pure_live/core/danmaku/empty_danmaku.dart';
import 'package:pure_live/core/interface/live_danmaku.dart';
import 'package:pure_live/core/common/core_log.dart';
import 'package:pure_live/core/common/http_client.dart';
import 'package:pure_live/core/utils/live_quality_label.dart';
import 'package:pure_live/modules/live_play/controllers/player_controller.dart';

/// 小红书直播（方案 A：链接观看）
///
/// 小红书未向客户端开放免签名的直播列表/弹幕接口（`live-room.xiaohongshu.com`
/// 的 squarefeed / category / room / join 系列接口要求 `x-s`/`x-t` 浏览器签名，
/// 纯 HTTP 客户端会被拒绝）。本适配器走免签名的 SSR 通道：
///
/// - 直播间页 `https://www.xiaohongshu.com/livestream/{roomId}`
/// - 主播主页 `https://www.xiaohongshu.com/user/profile/{userId}`
///
/// 使用移动端 UA 请求后解析 `window.__INITIAL_STATE__` 中的 `liveStream`：
/// 直播状态、标题、封面、主播、人数、`pullConfig` 多档流（h264/h265 master_url）
/// 与 `deeplink`（flv/m3u8 回退）。
///
/// 与 streamget / rust-srec / biliLive-tools 三个独立实现交叉验证过的契约：
/// - 标题含"回放"视为下播；
/// - `liveStatus != "success"` 视为未开播；
/// - `pullConfig` 缺失时用 `deeplink.flvUrl` 参数构造
///   `http://live-source-play.xhscdn.com/live/{room_id}.flv|.m3u8`。
class XhsSite extends LiveSite implements LiveSiteRoomRefresher, LiveSiteRecordRoomResolver {
  static const String siteId = 'xhs';

  /// 移动端 UA 与 streamget/rust-srec/biliLive-tools 一致；SSR 页面会按是否
  /// 移动端返回不同的 liveStream 结构，PC UA 可能拿不到 roomInfo。
  static const String _mobileUserAgent =
      'ios/7.830 (ios 17.0; ; iPhone 15 (A2846/A3089/A3090/A3092))';

  static const Map<String, String> _pageHeaders = {
    'user-agent': _mobileUserAgent,
    'xy-common-params': 'platform=iOS&sid=session.1722166379345546829388',
    'referer': 'https://app.xhs.cn/',
    'accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
  };

  @override
  String get id => siteId;

  @override
  String get name => '小红书直播';

  @override
  LiveDanmaku getDanmaku() => EmptyDanmaku();

  // ---------------------------------------------------------------------------
  // 页面 URL 与页面解析
  // ---------------------------------------------------------------------------

  /// 直播间 ID 是纯数字（约 18~21 位）；主播主页 ID 是 24 位十六进制串。
  static final RegExp _numericRoomId = RegExp(r'^\d{6,30}$');

  static String roomPageUrl(String roomIdOrUserId) {
    final id = roomIdOrUserId.trim();
    if (_numericRoomId.hasMatch(id)) {
      return 'https://www.xiaohongshu.com/livestream/$id';
    }
    return 'https://www.xiaohongshu.com/user/profile/$id';
  }

  static bool looksLikeRoomId(String value) => _numericRoomId.hasMatch(value.trim());

  /// 提取 `window.__INITIAL_STATE__` 并修正常见的裸 `undefined` 值。
  ///
  /// 使用与 rust-srec 一致的边界正则：只在 `:`/`,`/`[` 之后替换，避免误伤
  /// 字符串内容中的 "undefined"（如主播昵称）。
  @visibleForTesting
  static String? extractInitialStateJson(String html) {
    final match = RegExp(
      r'<script>window\.__INITIAL_STATE__=(.*?)</script>',
      caseSensitive: false,
      dotAll: true,
    ).firstMatch(html);
    if (match == null) return null;
    final raw = match.group(1)?.trim() ?? '';
    if (raw.isEmpty) return null;
    return raw.replaceAllMapped(RegExp(r'([:,\[])\s*undefined\b'), (m) => '${m.group(1)}null');
  }

  /// 解析页面 HTML，失败返回 null（结构缺失/JSON 损坏）。
  static Map<String, dynamic>? parseInitialState(String html) {
    final jsonText = extractInitialStateJson(html);
    if (jsonText == null) return null;
    try {
      final decoded = jsonDecode(jsonText);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  /// 从 `liveStream` 结构构建房间（纯函数，便于测试）。
  ///
  /// [inputRoomId] 仅在没有 roomInfo.roomId 时回退使用。
  /// [strict] 为 true 时（刷新/录制）结构缺失抛出 [FormatException]，不掩盖为下播。
  static LiveRoom roomFromLiveStream(
    Map<String, dynamic> liveStream, {
    required String inputRoomId,
    bool strict = false,
  }) {
    final pageStatus = _stringValue(liveStream['pageStatus']);
    final liveStatus = _stringValue(liveStream['liveStatus']);
    final roomData = _asMap(liveStream['roomData']);
    final roomInfo = _asMap(roomData?['roomInfo']);
    if (roomInfo == null) {
      // 结构漂移：普通路径返回下播房间，刷新/录制路径必须向上抛出，
      // 避免把接口错误当成"主播下播"。
      if (strict) {
        throw FormatException('xhs room metadata is missing (pageStatus=$pageStatus, liveStatus=$liveStatus)');
      }
      return LiveRoom(roomId: inputRoomId.trim(), platform: siteId, status: false, liveStatus: LiveStatus.offline);
    }

    final hostInfo = _asMap(roomData!['hostInfo']) ?? {};
    final nick = _stringValue(hostInfo['nickName']) ?? '';
    final avatar = _stringValue(hostInfo['avatar']) ?? '';
    final title = _stringValue(roomInfo['roomTitle']);

    final isLive = liveStatus == 'success';
    final isReplay = title != null && title.contains('回放');
    final effectiveStatus = isLive && !isReplay;

    final roomId = _stringValue(roomInfo['roomId']) ?? _stringValue(liveStream['roomId']) ?? inputRoomId;
    final cover = _stringValue(roomInfo['roomCover']) ?? '';
    final deeplink = _stringValue(roomInfo['deeplink']);
    final pullConfig = _normalizePullConfig(roomInfo['pullConfig']);

    final displayCount = _asMap(liveStream['displayCountInfo'])?['displayCount'];
    final watching = _displayCountText(displayCount);

    // 未开播/已结束（liveStatus != "success"，如 "fail"/"end"/not_found）
    // 或标题为回放时没有可消费的流，不构造回退地址以免下发假直链。
    final resolvedFlv = effectiveStatus ? _resolveFlvUrl(roomId, deeplink) : '';
    final resolvedM3u8 = resolvedFlv.isEmpty ? '' : resolvedFlv.replaceFirst(RegExp(r'\.flv$'), '.m3u8');

    return LiveRoom(
      roomId: roomId,
      userId: _stringValue(liveStream['userId']) ?? '',
      link: deeplink ?? '',
      title: (title ?? '').isNotEmpty ? (title ?? '') : '$nick 的直播',
      nick: nick,
      avatar: avatar,
      cover: cover,
      watching: watching,
      popularity: watching,
      audienceMetricType: AudienceMetricType.popularity,
      platform: siteId,
      status: effectiveStatus,
      liveStatus: effectiveStatus ? LiveStatus.live : LiveStatus.offline,
      data: <String, dynamic>{
        'pullConfig': pullConfig,
        'deeplink': deeplink ?? '',
        'roomId': roomId,
        'flvUrl': resolvedFlv,
        'm3u8Url': resolvedM3u8,
      },
    );
  }

  /// pullConfig 可能是 JSON 字符串（rust-srec 也处理了这种形状）。
  static dynamic _normalizePullConfig(dynamic raw) {
    if (raw == null) return null;
    if (raw is String) {
      try {
        return jsonDecode(raw);
      } catch (_) {
        return null;
      }
    }
    return raw is Map ? raw : null;
  }

  /// 人数口径：SSR 的 displayCountInfo 是"观看人数/热度"的展示值，未区分在线
  /// 并发还是累计；按平台热度口径上报，由"观看数据与排行口径"设置统一管理。
  static String _displayCountText(dynamic value) {
    if (value == null) return '';
    final text = value.toString().trim();
    if (text.isEmpty || text == 'null') return '';
    return text;
  }

  /// 从 deeplink 提取 flvUrl 参数；缺失时用 roomId 构造标准回退地址。
  static String _resolveFlvUrl(String roomId, String? deeplink) {
    if (deeplink != null && deeplink.isNotEmpty) {
      final uri = Uri.tryParse(deeplink);
      if (uri != null) {
        final flv = uri.queryParameters['flvUrl'];
        if (flv != null && flv.trim().isNotEmpty) {
          return flv.trim();
        }
        final roomParam = uri.queryParameters['room_id'];
        if (roomParam != null && roomParam.isNotEmpty) {
          return 'http://live-source-play.xhscdn.com/live/${roomParam.trim()}.flv';
        }
      }
    }
    if (roomId.isNotEmpty) {
      return 'http://live-source-play.xhscdn.com/live/${roomId.trim()}.flv';
    }
    return '';
  }

  // ---------------------------------------------------------------------------
  // 档位（pullConfig）
  // ---------------------------------------------------------------------------

  /// 读取 detail.data 中的流配置，生成稳定档位列表。
  static List<LivePlayQuality> qualitiesFromData(dynamic data) {
    final result = <LivePlayQuality>[];
    if (data is! Map) return result;

    final pullConfig = _normalizePullConfig(data['pullConfig']);
    if (pullConfig is Map) {
      for (final entry in const [
        ('h264', 'avc'),
        ('h265', 'hevc'),
      ]) {
        final streams = pullConfig[entry.$1];
        if (streams is! List) continue;
        for (final raw in streams.whereType<Map>()) {
          final masterUrl = raw['master_url']?.toString().trim() ?? '';
          if (masterUrl.isEmpty) continue;
          final rawName = raw['quality_type_name']?.toString().trim() ?? '';
          final qualityType = raw['quality_type']?.toString().trim() ?? '';
          final isBackup = masterUrl.contains('bak');
          final identity = '${entry.$2}|${rawName.isNotEmpty ? rawName : qualityType}|${isBackup ? 'bak' : 'main'}';
          if (result.any((q) => q.id == identity)) continue;
          result.add(
            LivePlayQuality(
              quality: LiveQualityLabel.normalize(
                platform: siteId,
                rawLabel: rawName.isNotEmpty ? rawName : qualityType,
                id: identity,
              ),
              id: identity,
              sort: _qualitySort(rawName, entry.$2, isBackup),
              data: <String, dynamic>{
                'masterUrl': masterUrl,
                'qualityTypeName': rawName,
                'qualityType': qualityType,
                'codec': entry.$2,
                'bak': isBackup,
              },
            ),
          );
        }
      }
    }

    final flvUrl = data['flvUrl']?.toString().trim() ?? '';
    if (result.isEmpty && flvUrl.isNotEmpty) {
      result.add(
        LivePlayQuality(
          quality: '默认',
          id: 'deeplink',
          sort: 0,
          data: <String, dynamic>{'deeplink': true},
        ),
      );
    }

    result.sort((a, b) => b.sort.compareTo(a.sort));
    return result;
  }

  static int _qualitySort(String rawName, String codec, bool isBackup) {
    final rank = switch (rawName.toLowerCase()) {
      '原画' || '原始' || 'source' || 'original' => 6,
      '蓝光' || '超清' || 'uhd' => 5,
      '高清' || 'hd' => 4,
      '标清' || 'sd' || '流畅' || 'fluent' => 3,
      _ => 2,
    };
    return rank * 1000000 + (codec == 'avc' ? 50000 : 0) - (isBackup ? 1 : 0);
  }

  /// 从 detail.data 路由到实际播放地址（纯函数，便于测试）。
  static List<String> urlsFromPlayQuality(dynamic data, LivePlayQuality quality) {
    final qualityData = quality.data;
    if (qualityData is Map) {
      final masterUrl = qualityData['masterUrl']?.toString().trim() ?? '';
      if (masterUrl.isNotEmpty) return [masterUrl];
    }
    if (data is! Map) return const [];
    final urls = <String>[
      if ((data['flvUrl']?.toString().trim() ?? '').isNotEmpty) data['flvUrl'].toString().trim(),
      if ((data['m3u8Url']?.toString().trim() ?? '').isNotEmpty) data['m3u8Url'].toString().trim(),
    ];
    return List<String>.unmodifiable(urls);
  }

  // ---------------------------------------------------------------------------
  // LiveSite 接口
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>?> _fetchLiveStream(String inputRoomId, {bool strict = false}) async {
    final pageUrl = roomPageUrl(inputRoomId);
    final html = await HttpClient.instance.getText(pageUrl, header: _pageHeaders);
    final state = parseInitialState(html);
    if (state == null) {
      if (strict) {
        throw const FormatException('xhs page missing __INITIAL_STATE__');
      }
      return null;
    }
    final liveStream = _asMap(state['liveStream']);
    if (liveStream == null) {
      if (strict) {
        throw const FormatException('xhs page missing liveStream metadata');
      }
      return null;
    }
    return liveStream;
  }

  @override
  Future<LiveRoom> getRoomDetail({required String platform, required String roomId}) async {
    try {
      final liveStream = await _fetchLiveStream(roomId);
      if (liveStream == null) {
        return LiveRoom(roomId: roomId, platform: siteId).getLiveRoomWithError();
      }
      return roomFromLiveStream(liveStream, inputRoomId: roomId);
    } catch (e) {
      CoreLog.error(e);
      if (Get.isRegistered<PlayerController>()) {
        final playerController = Get.find<PlayerController>();
        final currentRoom = playerController.currentRoom;
        if (currentRoom?.hasIdentity(platform: siteId, roomId: roomId) == true) {
          return currentRoom!.getLiveRoomWithError();
        }
      }
      return LiveRoom(roomId: roomId, platform: siteId).getLiveRoomWithError();
    }
  }

  @override
  Future<LiveRoom> getRoomDetailForRefresh({required String platform, required String roomId}) async {
    final liveStream = await _fetchLiveStream(roomId, strict: true);
    // 刷新路径：结构缺失时向上抛出（favorite 校验保留未知状态），只有平台
    // 明确给出非 success 状态才返回下播房间。
    return roomFromLiveStream(liveStream!, inputRoomId: roomId, strict: true);
  }

  @override
  Future<LiveRoom> getRoomDetailForRecording({required String platform, required String roomId}) async {
    final liveStream = await _fetchLiveStream(roomId, strict: true);
    return roomFromLiveStream(liveStream!, inputRoomId: roomId, strict: true);
  }

  @override
  Future<List<LivePlayQuality>> getPlayQualites({required LiveRoom detail}) async {
    return qualitiesFromData(detail.data);
  }

  @override
  Future<List<String>> getPlayUrls({required LiveRoom detail, required LivePlayQuality quality}) async {
    return urlsFromPlayQuality(detail.data, quality);
  }

  @override
  Future<bool> getLiveStatus({required String platform, required String roomId}) async {
    final liveStream = await _fetchLiveStream(roomId, strict: false);
    if (liveStream == null) return false;
    return roomFromLiveStream(liveStream, inputRoomId: roomId).liveStatus == LiveStatus.live;
  }
}

// ---------------------------------------------------------------------------
// 辅助
// ---------------------------------------------------------------------------

String? _stringValue(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty || text == 'null' ? null : text;
}

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return null;
}
