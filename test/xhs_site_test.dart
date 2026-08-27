import 'package:flutter_test/flutter_test.dart';
import 'package:pure_live/core/site/xhs/xhs_site.dart';
import 'package:pure_live/common/utils/live_url_tool.dart';
import 'package:pure_live/core/sites.dart';
import 'package:pure_live/common/models/live_room.dart';
import 'package:pure_live/modules/search/web_search_room_parser.dart';

/// 小红书 SSR 解析的确定性测试。
///
/// 夹具基于 live-room 网页实际返回结构（2026-08 抓包）与 streamget /
/// rust-srec / biliLive-tools 交叉验证的字段契约，不依赖真实网络。
const String _liveHtml = r'''
<!doctype html><html><body>
<script>window.__INITIAL_STATE__={"global":{"appSettings":{}},"liveStream":{"pageStatus":"success","liveStatus":"success","errorMessage":"","roomData":{"hostInfo":{"avatar":"https://sns-avatar-qc.xhscdn.com/avatar/a1.jpg","nickName":"主播一号"},"roomInfo":{"roomId":570426783767794211,"roomTitle":"晚间整活直播","roomCover":"https://live-i1.xhscdn.com/live_helper/c1.jpg","pullConfig":{"h264":[{"master_url":"https://pull-xhs-avc.example/stream.m3u8","quality_type_name":"原画","quality_type":"HD"}],"h265":[{"master_url":"https://pull-xhs-hevc.example/stream.m3u8","quality_type_name":"原画","quality_type":"HD"}],"width":1920,"height":1080},"deeplink":"xhsdiscover://live_audience?room_id=570426783767794211&flvUrl=http%3A%2F%2Flive.xhscdn.com%2Flive%2F570426783767794211.flv&host_nickname=%E4%B8%BB%E6%92%AD%E4%B8%80%E5%8F%B7"}},"displayCountInfo":{"displayCount":"1.2万","displayType":2},"roomId":"570426783767794211","userId":"6a90256f000000001302240d"}}</script>
</body></html>
''';

const String _offlineHtml = r'''
<html><body><script>window.__INITIAL_STATE__={"liveStream":{"pageStatus":"success","liveStatus":"fail","errorMessage":"","roomData":{"hostInfo":{"avatar":"","nickName":"主播一号"},"roomInfo":{}},"displayCountInfo":{"displayCount":"0","displayType":2},"roomId":"570426783767794211"}}</script></body></html>
''';

const String _replayHtml = r'''
<html><body><script>window.__INITIAL_STATE__={"liveStream":{"pageStatus":"success","liveStatus":"success","errorMessage":"","roomData":{"hostInfo":{"nickName":"主播一号"},"roomInfo":{"roomId":570426783767794211,"roomTitle":"2026-08-20 直播间回放","deeplink":"xhsdiscover://live?room_id=570426783767794211&flvUrl=http%3A%2F%2Flive.xhscdn.com%2Flive%2F570426783767794211.flv"}},"displayCountInfo":{"displayCount":"0","displayType":2}}}</script></body></html>
''';

const String _undefinedHtml = r'''
<html><body><script>window.__INITIAL_STATE__={"liveStream":{"pageStatus":"success","liveStatus":"success","errorMessage":"","roomData":{"hostInfo":{"nickName":"xundefinedy主播"},"roomInfo":{"roomId":1,"roomTitle":undefined,"pullConfig":undefined,"deeplink":undefined}},"displayCountInfo":undefined,"roomId":"1"}}</script></body></html>
''';

const String _stringifiedPullConfigHtml = r'''
<html><body><script>window.__INITIAL_STATE__={"liveStream":{"pageStatus":"success","liveStatus":"success","roomData":{"hostInfo":{"nickName":"主播"},"roomInfo":{"roomId":999,"roomTitle":"测试","pullConfig":"{\"h264\":[{\"master_url\":\"https://cdn.example/s.m3u8\",\"quality_type_name\":\"超清\",\"quality_type\":\"HD\"}]}","deeplink":"xhsdiscover://live?room_id=999"}},"displayCountInfo":{"displayCount":"88","displayType":2}}}</script></body></html>
''';

void main() {
  group('XhsSite 页面解析', () {
    test('提取 __INITIAL_STATE__ 并修正常见 undefined', () {
      final jsonText = XhsSite.extractInitialStateJson(_liveHtml);
      expect(jsonText, isNotNull);
      expect(jsonText, contains('"liveStream"'));

      // 只替换值位置的 bare undefined，不误伤字符串内容。
      final fixed = XhsSite.extractInitialStateJson(_undefinedHtml)!;
      expect(fixed, contains(':null'));
      expect(fixed, contains('xundefinedy'));
    });

    test('缺 script 返回 null', () {
      expect(XhsSite.extractInitialStateJson('<html>no state</html>'), isNull);
    });

    test('live 房间字段完整映射（数量口径为热度）', () {
      final state = XhsSite.parseInitialState(_liveHtml)!;
      final liveStream = state['liveStream'] as Map<String, dynamic>;
      final room = XhsSite.roomFromLiveStream(liveStream, inputRoomId: '570426783767794211');

      expect(room.roomId, '570426783767794211');
      expect(room.platform, Sites.xhsSite);
      expect(room.nick, '主播一号');
      expect(room.avatar, contains('sns-avatar-qc.xhscdn.com'));
      expect(room.title, '晚间整活直播');
      expect(room.cover, contains('live-i1.xhscdn.com'));
      expect(room.watching, '1.2万');
      expect(room.popularity, '1.2万');
      expect(room.audienceMetricType, AudienceMetricType.popularity);
      expect(room.liveStatus, LiveStatus.live);
      expect(room.status, isTrue);

      // deeplink 的 flvUrl 优先；m3u8 由 flv 派生。
      final data = room.data as Map<String, dynamic>;
      expect(data['flvUrl'], 'http://live.xhscdn.com/live/570426783767794211.flv');
      expect(data['m3u8Url'], 'http://live.xhscdn.com/live/570426783767794211.m3u8');
      expect(data['pullConfig'], isA<Map>());
    });

    test('pullConfig 为 JSON 字符串时也能解析', () {
      final state = XhsSite.parseInitialState(_stringifiedPullConfigHtml)!;
      final room =
          XhsSite.roomFromLiveStream(state['liveStream'] as Map<String, dynamic>, inputRoomId: '999');
      expect(room.liveStatus, LiveStatus.live);
      final qualities = XhsSite.qualitiesFromData(room.data);
      expect(qualities, hasLength(1));
      expect(qualities.single.quality, '超清');
    });

    test('liveStatus=fail 视为下播（平台明确无直播）', () {
      final state = XhsSite.parseInitialState(_offlineHtml)!;
      final room =
          XhsSite.roomFromLiveStream(state['liveStream'] as Map<String, dynamic>, inputRoomId: '570426783767794211');
      expect(room.liveStatus, LiveStatus.offline);
      expect(room.status, isFalse);
    });

    test('标题含回放视为下播', () {
      final state = XhsSite.parseInitialState(_replayHtml)!;
      final room =
          XhsSite.roomFromLiveStream(state['liveStream'] as Map<String, dynamic>, inputRoomId: '570426783767794211');
      expect(room.liveStatus, LiveStatus.offline);
    });

    test('结构漂移：普通路径下播、严格路径抛出', () {
      final broken = <String, dynamic>{
        'liveStream': {'pageStatus': 'success', 'liveStatus': 'success'},
      };
      final room = XhsSite.roomFromLiveStream(broken, inputRoomId: '123');
      expect(room.liveStatus, LiveStatus.offline);
      expect(
        () => XhsSite.roomFromLiveStream(broken, inputRoomId: '123', strict: true),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('XhsSite 档位与播放地址', () {
    final state = XhsSite.parseInitialState(_liveHtml)!;
    final room =
        XhsSite.roomFromLiveStream(state['liveStream'] as Map<String, dynamic>, inputRoomId: '570426783767794211');

    test('pullConfig h264/h265 生成两档，h264 优先', () {
      final qualities = XhsSite.qualitiesFromData(room.data);
      expect(qualities, hasLength(2));
      expect(qualities.first.quality, '原画');
      expect((qualities.first.data as Map)['codec'], 'avc');
      expect((qualities.last.data as Map)['codec'], 'hevc');
      expect(qualities.first.sort, greaterThan(qualities.last.sort));
    });

    test('getPlayUrls 返回所选档 master_url', () {
      final qualities = XhsSite.qualitiesFromData(room.data);
      final urls = XhsSite.urlsFromPlayQuality(room.data, qualities.first);
      expect(urls, ['https://pull-xhs-avc.example/stream.m3u8']);
    });

    test('无 pullConfig 时生成 deeplink 单档并返回 flv+m3u8', () {
      final offline = XhsSite.roomFromLiveStream(
        XhsSite.parseInitialState(_offlineHtml)!['liveStream'] as Map<String, dynamic>,
        inputRoomId: '570426783767794211',
      );
      final qualities = XhsSite.qualitiesFromData(offline.data);
      expect(qualities, hasLength(1));
      expect(qualities.single.id, 'deeplink');
      // offline 房间 deeplink 缺 flvUrl：按 roomId 构造标准回退。
      final urls = XhsSite.urlsFromPlayQuality(offline.data, qualities.single);
      expect(urls.first, 'http://live-source-play.xhscdn.com/live/570426783767794211.flv');
      expect(urls.last, endsWith('.m3u8'));
    });
  });

  group('XhsSite 房间 ID 归一化', () {
    test('数字为直播间 ID，其余为主播主页', () {
      expect(XhsSite.roomPageUrl('570426783767794211'),
          'https://www.xiaohongshu.com/livestream/570426783767794211');
      expect(XhsSite.roomPageUrl('6a90256f000000001302240d'),
          'https://www.xiaohongshu.com/user/profile/6a90256f000000001302240d');
      expect(XhsSite.looksLikeRoomId('570426783767794211'), isTrue);
      expect(XhsSite.looksLikeRoomId('6a90256f000000001302240d'), isFalse);
    });
  });

  group('WebSearchRoomParser 小红书 URL', () {
    test('直播间页', () {
      final target = WebSearchRoomParser.parse('https://www.xiaohongshu.com/livestream/570426783767794211');
      expect(target, isNotNull);
      expect(target!.platform, Sites.xhsSite);
      expect(target.roomId, '570426783767794211');
    });

    test('主播主页', () {
      final target =
          WebSearchRoomParser.parse('https://www.xiaohongshu.com/user/profile/6a90256f000000001302240d');
      expect(target, isNotNull);
      expect(target!.platform, Sites.xhsSite);
      expect(target.roomId, '6a90256f000000001302240d');
    });

    test('短链与未知路径不识别', () {
      expect(WebSearchRoomParser.parse('https://xhslink.com/m/abc123'), isNull);
      expect(WebSearchRoomParser.parse('https://www.xiaohongshu.com/livestream/abc'), isNull);
      expect(WebSearchRoomParser.parse('https://www.xiaohongshu.com/search/xxx'), isNull);
    });

    test('其他平台不回归', () {
      expect(WebSearchRoomParser.parse('https://live.bilibili.com/123')!.platform, Sites.bilibiliSite);
      expect(WebSearchRoomParser.parse('https://live.douyin.com/123')!.platform, Sites.douyinSite);
    });
  });

  group('LiveUrlTool 小红书链接（工具箱解析入口）', () {
    test('直播间页', () async {
      final result = await LiveUrlTool.parseLiveUrl('https://www.xiaohongshu.com/livestream/570426783767794211');
      expect(result, ['570426783767794211', Sites.xhsSite]);
    });

    test('主播主页', () async {
      final result =
          await LiveUrlTool.parseLiveUrl('https://www.xiaohongshu.com/user/profile/6a90256f000000001302240d');
      expect(result, ['6a90256f000000001302240d', Sites.xhsSite]);
    });

    test('整段分享文本中提取链接', () async {
      final result = await LiveUrlTool.parseLiveUrl(
        '我在小红书直播：https://www.xiaohongshu.com/livestream/570426783767794211?source=share 快来看！',
      );
      expect(result, ['570426783767794211', Sites.xhsSite]);
    });

    test('抖音等既有平台不回归', () async {
      final result = await LiveUrlTool.parseLiveUrl('https://live.douyin.com/123456');
      expect(result, ['123456', Sites.douyinSite]);
    });
  });

  group('Sites 注册', () {
    test('xhs 在支持列表与 of 查找中', () {
      expect(Sites.isSupported(Sites.xhsSite), isTrue);
      expect(Sites.supportSites.map((s) => s.id), contains(Sites.xhsSite));
      final site = Sites.of(Sites.xhsSite);
      expect(site.name, isNotEmpty);
      expect(site.logo, 'assets/images/xhs.png');
    });
  });

  test('LiveRoom 人数口径为热度', () {
    final room = LiveRoom(platform: Sites.xhsSite);
    expect(room.audienceCapability.hasPopularity, isTrue);
    expect(room.audienceCapability.supportsConcurrentOnline, isFalse);
    expect(room.effectiveAudienceMetricType, AudienceMetricType.popularity);
  });
}
