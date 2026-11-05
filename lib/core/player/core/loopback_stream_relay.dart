import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:pure_live/core/logging/core_log.dart';

/// Feeds one live stream to the player over loopback instead of letting the
/// player talk to the CDN itself.
///
/// Some CDNs answer Dart's HTTP client with 200 and the stream, then close the
/// connection when the bundled libmpv asks for the same URL — observed on
/// Windows with Douyu's FLV line, where the app read 66 KB of `video/x-flv` in
/// the same second the player reported the stream unusable. The CDN, not the
/// player, decides who it talks to, so the app reads the bytes and serves them
/// on `127.0.0.1`, where nothing inspects the client.
///
/// One relay serves one upstream URL and lives as long as its lease. Range and
/// HEAD requests are forwarded, so a seek into a finished stream still works.
class LoopbackStreamRelay {
  LoopbackStreamRelay._({
    required this.server,
    required this.client,
    required this.upstream,
    required this.headers,
    required this.secret,
  });

  final HttpServer server;
  final HttpClient client;
  final Uri upstream;
  final Map<String, String> headers;
  final String secret;
  bool _closed = false;

  /// The URL handed to the player.
  Uri get inputUri => Uri(
    scheme: 'http',
    host: InternetAddress.loopbackIPv4.address,
    port: server.port,
    path: '/$secret/stream',
  );

  bool get isClosed => _closed;

  static final Random _random = Random();

  static String _newSecret() {
    const alphabet = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List<String>.generate(24, (_) => alphabet[_random.nextInt(alphabet.length)]).join();
  }

  /// Starts relaying [source]. The caller owns the returned relay and must
  /// [close] it when the source is no longer playing.
  static Future<LoopbackStreamRelay> start({
    required Uri source,
    Map<String, String> headers = const <String, String>{},
    String Function(Uri url)? findProxy,
  }) async {
    final scheme = source.scheme.toLowerCase();
    if ((scheme != 'http' && scheme != 'https') || source.host.isEmpty) {
      throw ArgumentError.value(source, 'source', 'Loopback relay needs an http(s) source');
    }

    final client = HttpClient()..connectionTimeout = const Duration(seconds: 15);
    client.findProxy = findProxy ?? ((_) => 'DIRECT');
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0, shared: false);
    final relay = LoopbackStreamRelay._(
      server: server,
      client: client,
      upstream: source,
      headers: headers,
      secret: _newSecret(),
    );
    server.listen(relay._handle, onError: (Object error) {
      CoreLog.w('loopback relay server error: $error');
    });
    CoreLog.i('loopback relay ${source.host}${source.path} -> ${relay.inputUri}');
    return relay;
  }

  Future<void> _handle(HttpRequest request) async {
    if (_closed || request.uri.path != '/$secret/stream') {
      request.response.statusCode = HttpStatus.notFound;
      await request.response.close();
      return;
    }

    HttpClientRequest? outbound;
    try {
      outbound = await client.openUrl(request.method, upstream);
      headers.forEach((name, value) => outbound!.headers.set(name, value));
      for (final name in const <String>['range', 'if-range', 'user-agent', 'referer']) {
        final value = request.headers.value(name);
        if (value != null && value.isNotEmpty) outbound.headers.set(name, value);
      }
      final response = await outbound.close();

      request.response.statusCode = response.statusCode;
      for (final name in const <String>[
        HttpHeaders.contentTypeHeader,
        HttpHeaders.contentLengthHeader,
        HttpHeaders.acceptRangesHeader,
        HttpHeaders.contentRangeHeader,
        HttpHeaders.cacheControlHeader,
      ]) {
        final value = response.headers.value(name);
        if (value != null) request.response.headers.set(name, value);
      }
      // Live streams never end by themselves; flush per chunk so the player
      // receives bytes as they arrive instead of after a buffer fills.
      await for (final chunk in response) {
        request.response.add(chunk);
        await request.response.flush();
      }
      await request.response.close();
    } catch (error) {
      if (error is! HttpException && error is! SocketException) {
        CoreLog.w('loopback relay failed: $error');
      }
      try {
        await request.response.close();
      } catch (_) {
        // The player may already have gone away.
      }
    } finally {
      outbound?.abort();
    }
  }

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    client.close(force: true);
    await server.close(force: true);
  }
}
