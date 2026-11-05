@Tags(['probe'])
library;

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

/// Fetches the first bytes of a stream with Dart's own HTTP stack.
///
/// libmpv is refused by some Chinese CDNs while curl and Dart are accepted, so
/// the question this probe answers is whether the app could relay the bytes
/// itself instead of letting mpv talk to the CDN.
///
///   PURELIVE_FETCH_PROBE=1
///   PURELIVE_FETCH_URL=<stream url>
///   flutter test tool/probes/stream_fetch_probe_test.dart
void main() {
  final enabled = Platform.environment['PURELIVE_FETCH_PROBE'] == '1';
  final url = Platform.environment['PURELIVE_FETCH_URL'] ?? '';

  test('Dart 能否直接取到该流', () async {
    if (!enabled) {
      // ignore: avoid_print
      print('[fetch-probe] skipped (set PURELIVE_FETCH_PROBE=1)');
      return;
    }
    expect(url, isNotEmpty, reason: 'PURELIVE_FETCH_URL 未设置');

    final client = HttpClient()..connectionTimeout = const Duration(seconds: 15);
    final request = await client.getUrl(Uri.parse(url));
    request.headers.set(
      HttpHeaders.userAgentHeader,
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/128.0.0.0 Safari/537.36',
    );
    request.headers.set(HttpHeaders.refererHeader, 'https://www.douyu.com/');
    final response = await request.close();

    final sample = BytesBuilder();
    await for (final chunk in response.timeout(const Duration(seconds: 20))) {
      sample.add(chunk);
      if (sample.length >= 256 * 1024) break;
    }
    client.close(force: true);

    final bytes = sample.takeBytes();
    // ignore: avoid_print
    print('[fetch-probe] status=${response.statusCode} type=${response.headers.contentType} got=${bytes.length}');
    // ignore: avoid_print
    print('[fetch-probe] head=${bytes.take(16).map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}');
    // ignore: avoid_print
    print('[fetch-probe] flv=${bytes.length >= 3 && bytes[0] == 0x46 && bytes[1] == 0x4C && bytes[2] == 0x56}');

    expect(response.statusCode, 200);
    expect(bytes.length, greaterThan(0));
  }, timeout: const Timeout(Duration(minutes: 2)));
}
