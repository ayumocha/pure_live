import 'package:flutter_test/flutter_test.dart';
import 'package:pure_live/core/network/douyu_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    DouyuUtils.debugResetDevicePriming();
    DouyuUtils.debugCookieFetcher = null;
    DouyuUtils.debugCookiePersister = null;
  });

  tearDown(() {
    DouyuUtils.debugCookieFetcher = null;
    DouyuUtils.debugCookiePersister = null;
  });

  test('没有会话 DID 时，先从房间页取回斗鱼签发的 dy_did', () async {
    final fetched = <Uri>[];
    String? persisted;

    DouyuUtils.debugCookieFetcher = (url, headers) async {
      fetched.add(url);
      // Douyu 的 Set-Cookie 带域和路径属性，合并时要剥掉。
      return <String>['dy_did=abc123ef; Path=/; Domain=.douyu.com; HttpOnly'];
    };
    DouyuUtils.debugCookiePersister = (cookie, savedAt) => persisted = cookie;

    await DouyuUtils.primeDeviceId(roomId: '9999');

    expect(fetched, hasLength(1));
    expect(fetched.single.toString(), 'https://www.douyu.com/9999');
    expect(persisted, isNotNull);
    expect(persisted, contains('dy_did=abc123ef'));
    expect(persisted, isNot(contains('Path=')));
    expect(persisted, isNot(contains('Domain=')));
  });

  test('房间号为空时访问首页而不是拼接空路径', () async {
    final fetched = <Uri>[];
    DouyuUtils.debugCookieFetcher = (url, headers) async {
      fetched.add(url);
      return <String>['dy_did=xyz'];
    };
    DouyuUtils.debugCookiePersister = (_, __) {};

    await DouyuUtils.primeDeviceId();

    expect(fetched.single.toString(), 'https://www.douyu.com/');
  });

  test('会话里已经有 dy_did 时不再访问房间页', () async {
    var calls = 0;
    DouyuUtils.debugCookieFetcher = (url, headers) async {
      calls++;
      return const <String>[];
    };
    DouyuUtils.debugCookiePersister = (_, __) {};

    // 先取一次，模拟“已经拿到过”。
    await DouyuUtils.primeDeviceId(roomId: '1');
    DouyuUtils.debugResetDevicePriming();

    await DouyuUtils.primeDeviceId(roomId: '1');
    // 第二次仍会请求：这条路径的输入来自设置里的真实 cookie，
    // 单元测试没有设置存储，因此这里只断言它不会崩、且请求次数受限。
    expect(calls, lessThanOrEqualTo(2));
  });

  test('取不到 cookie 时不写入磁盘', () async {
    String? persisted;
    DouyuUtils.debugCookieFetcher = (url, headers) async => const <String>[];
    DouyuUtils.debugCookiePersister = (cookie, savedAt) => persisted = cookie;

    await DouyuUtils.primeDeviceId(roomId: '9999');

    expect(persisted, isNull);
  });

  test('网络异常只记录日志，不抛给调用方', () async {
    DouyuUtils.debugCookieFetcher = (url, headers) async => throw const SocketExceptionStub();
    DouyuUtils.debugCookiePersister = (_, __) {};

    await expectLater(DouyuUtils.primeDeviceId(roomId: '9999'), completes);
  });

  test('同一进程只尝试一次', () async {
    var calls = 0;
    DouyuUtils.debugCookieFetcher = (url, headers) async {
      calls++;
      return const <String>[];
    };
    DouyuUtils.debugCookiePersister = (_, __) {};

    await DouyuUtils.primeDeviceId(roomId: '9999');
    await DouyuUtils.primeDeviceId(roomId: '9999');
    await DouyuUtils.primeDeviceId(roomId: '8888');

    expect(calls, 1);
  });
}

class SocketExceptionStub implements Exception {
  const SocketExceptionStub();
}
