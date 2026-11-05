import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pure_live/core/player/core/loopback_stream_relay.dart';

/// The relay is the app's answer to a CDN that refuses the player, so it has to
/// behave like the upstream: same status, same content type, same bytes, and a
/// Range request that still returns partial content.
void main() {
  test('中继把上游的状态、类型和字节原样转给播放器', () async {
    final upstream = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final body = List<int>.generate(4096, (index) => index % 251);
    final requests = <String>[];
    upstream.listen((request) async {
      requests.add('${request.method} ${request.uri.path}');
      request.response.statusCode = HttpStatus.ok;
      request.response.headers.contentType = ContentType('video', 'x-flv');
      request.response.add(body);
      await request.response.close();
    });

    final relay = await LoopbackStreamRelay.start(
      source: Uri.parse('http://127.0.0.1:${upstream.port}/live/room.flv?token=abc'),
    );

    final client = HttpClient();
    final request = await client.getUrl(relay.inputUri);
    final response = await request.close();
    final received = await response.fold<List<int>>(<int>[], (all, chunk) => all..addAll(chunk));

    expect(response.statusCode, HttpStatus.ok);
    expect(response.headers.contentType?.mimeType, 'video/x-flv');
    expect(received, body);
    expect(requests, <String>['GET /live/room.flv']);

    client.close(force: true);
    await relay.close();
    await upstream.close(force: true);
  });

  test('中继转发 Range，播放器可以定位', () async {
    final upstream = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final body = List<int>.generate(1024, (index) => index % 256);
    upstream.listen((request) async {
      final range = request.headers.value(HttpHeaders.rangeHeader);
      if (range == null) {
        request.response.add(body);
      } else {
        request.response.statusCode = HttpStatus.partialContent;
        request.response.headers.set(HttpHeaders.contentRangeHeader, 'bytes 100-199/1024');
        request.response.add(body.sublist(100, 200));
      }
      await request.response.close();
    });

    final relay = await LoopbackStreamRelay.start(
      source: Uri.parse('http://127.0.0.1:${upstream.port}/archive.flv'),
    );

    final client = HttpClient();
    final request = await client.getUrl(relay.inputUri);
    request.headers.set(HttpHeaders.rangeHeader, 'bytes=100-199');
    final response = await request.close();
    final received = await response.fold<List<int>>(<int>[], (all, chunk) => all..addAll(chunk));

    expect(response.statusCode, HttpStatus.partialContent);
    expect(response.headers.value(HttpHeaders.contentRangeHeader), 'bytes 100-199/1024');
    expect(received, body.sublist(100, 200));

    client.close(force: true);
    await relay.close();
    await upstream.close(force: true);
  });

  test('关闭后中继拒绝请求并释放端口', () async {
    final upstream = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    upstream.listen((request) async {
      request.response.add(<int>[1, 2, 3]);
      await request.response.close();
    });

    final relay = await LoopbackStreamRelay.start(
      source: Uri.parse('http://127.0.0.1:${upstream.port}/live.flv'),
    );
    final port = relay.inputUri.port;
    await relay.close();
    expect(relay.isClosed, isTrue);

    var refused = false;
    try {
      final socket = await Socket.connect(InternetAddress.loopbackIPv4, port, timeout: const Duration(seconds: 2));
      socket.destroy();
    } on SocketException {
      refused = true;
    }
    expect(refused, isTrue, reason: '中继关闭后端口应不再接受连接');

    await upstream.close(force: true);
  });

  test('非 http(s) 源直接拒绝', () async {
    await expectLater(
      LoopbackStreamRelay.start(source: Uri.parse('rtmp://example.test/live')),
      throwsA(isA<ArgumentError>()),
    );
  });
}
