import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pure_live/core/network/douyu_native_http.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(DouyuNativeHttp.debugReset);

  group('响应解码', () {
    test('2xx 的 JSON 被解码成对象', () {
      final decoded = DouyuNativeHttp.decode(
        http.Response(json.encode({'error': 0, 'data': <String, dynamic>{'key': 'k'}}), 200),
      );

      expect(decoded, isA<Map>());
      expect((decoded as Map)['error'], 0);
    });

    test('非 JSON 的 2xx 原样返回字符串', () {
      expect(DouyuNativeHttp.decode(http.Response('<html></html>', 200)), '<html></html>');
    });

    test('空响应体返回 null', () {
      expect(DouyuNativeHttp.decode(http.Response('', 204)), isNull);
    });

    test('非 2xx 抛异常并带上状态码，交给上层重试逻辑', () {
      expect(
        () => DouyuNativeHttp.decode(http.Response('', 400)),
        throwsA(isA<DouyuNativeHttpException>().having((e) => e.statusCode, 'statusCode', 400)),
      );
    });
  });

  group('Set-Cookie 拆分', () {
    test('Expires 里的逗号不当作 cookie 分隔符', () {
      const header =
          'dy_did=abc; Path=/; Expires=Wed, 21 Oct 2026 07:28:00 GMT, acf_did=def; Path=/';
      expect(DouyuNativeHttp.splitSetCookies(header), hasLength(2));
      expect(DouyuNativeHttp.splitSetCookies(header).first, startsWith('dy_did=abc'));
      expect(DouyuNativeHttp.splitSetCookies(header).last, startsWith('acf_did=def'));
    });

    test('单个 cookie 原样返回', () {
      expect(DouyuNativeHttp.splitSetCookies('dy_did=abc; Path=/'), ['dy_did=abc; Path=/']);
    });
  });

  group('平台路由', () {
    test('平台不支持时返回 null，调用方保留原路径', () async {
      DouyuNativeHttp.debugDisable = true;

      expect(await DouyuNativeHttp.getJson('https://www.douyu.com/x'), isNull);
      expect(await DouyuNativeHttp.postFormJson('https://www.douyu.com/x', body: 'a=1'), isNull);
    });

    test('注入的客户端收到查询参数与请求头', () async {
      late Uri seen;
      late Map<String, String> seenHeaders;
      DouyuNativeHttp.debugClientOverride = MockClient((request) async {
        seen = request.url;
        seenHeaders = request.headers;
        return http.Response(json.encode({'error': 0}), 200);
      });

      final result = await DouyuNativeHttp.getJson(
        'https://www.douyu.com/wgapi/livenc/liveweb/websec/getEncryption',
        queryParameters: {'did': 'abc'},
        headers: {'referer': 'https://www.douyu.com/9999'},
      );

      expect(seen.queryParameters['did'], 'abc');
      expect(seenHeaders['referer'], 'https://www.douyu.com/9999');
      expect((result as Map)['error'], 0);
    });

    test('表单 POST 以 urlencoded 形式发出', () async {
      late String contentType;
      late String body;
      DouyuNativeHttp.debugClientOverride = MockClient((request) async {
        contentType = request.headers['content-type'] ?? '';
        body = request.body;
        return http.Response(json.encode({'error': 0, 'data': {'rate': 0}}), 200);
      });

      final result = await DouyuNativeHttp.postFormJson(
        'https://www.douyu.com/lapi/live/getH5PlayV1/9999',
        body: 'did=abc&tt=1',
      );

      expect(contentType, contains('application/x-www-form-urlencoded'));
      expect(body, 'did=abc&tt=1');
      expect((result as Map)['error'], 0);
    });
  });
}
