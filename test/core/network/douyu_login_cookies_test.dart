import 'package:flutter_test/flutter_test.dart';
import 'package:pure_live/core/network/douyu_login_cookies.dart';

void main() {
  group('斗鱼 H5 登录 cookie 解析', () {
    test('JWT + LTP0 + dy_did：可自动续期', () {
      final parsed = extractDouyuLoginCookies(const [
        DouyuCookieValue('acf_jwt_token', 'eyJhbGciOi.test.jwt'),
        DouyuCookieValue('LTP0', 'ltp-value'),
        DouyuCookieValue('dy_did', 'abc123'),
        DouyuCookieValue('acf_uid', '42'),
      ]);

      expect(parsed, isNotNull);
      expect(parsed!.hasSession, isTrue);
      expect(parsed.isRenewable, isTrue);
      expect(parsed.sessionToken, 'eyJhbGciOi.test.jwt');
      expect(parsed.longTerm, 'ltp-value');
      expect(parsed.deviceId, 'abc123');
      // 整组 cookie 会被原样存起来，供请求头使用。
      expect(parsed.header, contains('acf_jwt_token='));
      expect(parsed.header, contains('acf_uid=42'));
    });

    test('acf_auth 也能当会话令牌', () {
      final parsed = extractDouyuLoginCookies(const [
        DouyuCookieValue('acf_auth', 'auth-token'),
      ]);

      expect(parsed, isNotNull);
      expect(parsed!.sessionToken, 'auth-token');
      // 没有 LTP0 就没法续期，但仍算登录成功（只是到期需重新登录）。
      expect(parsed.isRenewable, isFalse);
    });

    test('只有设备 cookie 时不算登录', () {
      expect(
        extractDouyuLoginCookies(const [
          DouyuCookieValue('dy_did', 'abc'),
          DouyuCookieValue('acf_did', 'abc'),
        ]),
        isNull,
      );
    });

    test('空值与空白的 cookie 被忽略', () {
      final parsed = extractDouyuLoginCookies(const [
        DouyuCookieValue('acf_jwt_token', 'tok'),
        DouyuCookieValue('LTP0', '   '),
        DouyuCookieValue('', 'nolonger'),
      ]);

      expect(parsed, isNotNull);
      expect(parsed!.header, 'acf_jwt_token=tok');
      expect(parsed.longTerm, isNull);
    });

    test('没有任何 cookie 时返回 null', () {
      expect(extractDouyuLoginCookies(const []), isNull);
    });
  });
}
