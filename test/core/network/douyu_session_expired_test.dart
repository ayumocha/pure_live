import 'package:flutter_test/flutter_test.dart';
import 'package:pure_live/core/network/douyu_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() => DouyuUtils.guestMode = false);

  group('斗鱼登录过期（902）的游客重试', () {
    test('游客模式下不再携带贴入的账号 cookie', () {
      DouyuUtils.guestMode = true;

      final header = DouyuUtils.requestHeaders('5135383')['cookie'] ?? '';

      expect(header, contains('dy_did='));
      expect(header, contains('acf_did='));
      // 只有设备 cookie，没有任何登录态字段。
      expect(header, isNot(contains('; dy_auth=')));
    });

    test('退出游客模式后恢复请求头里的引用方与 agent', () {
      DouyuUtils.guestMode = false;
      final header = DouyuUtils.requestHeaders('5135383');

      expect(header['referer'], 'https://www.douyu.com/5135383');
      expect(header['origin'], 'https://www.douyu.com');
      expect(header['cookie'], contains('dy_did='));
    });

    test('902 是斗鱼的登录过期码，被单独识别', () {
      expect(DouyuUtils.sessionExpiredError, 902);
      expect(const DouyuSessionExpiredException().toString(), contains('902'));
    });
  });
}
