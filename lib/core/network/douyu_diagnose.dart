import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pure_live/core/logging/core_log.dart';

/// Records what the Douyu endpoints actually answered, so a failure on a device
/// we cannot debug can be reported instead of guessed at.
///
/// Only Douyu touches this: the platform is the one whose edge answers a bare
/// 400 to this client while accepting curl, and the device build is the only
/// place its answer can be observed. A bounded ring buffer keeps the cost at
/// zero during normal playback; the file is written on demand.
class DouyuDiagnose {
  DouyuDiagnose._();

  static const int _capacity = 40;

  /// The URL handed to the player last. The failure path re-fetches it with
  /// Dart's HTTP stack: a fresh token that Dart can read but the player cannot
  /// is a player problem, while a token Dart also rejects is a URL problem, and
  /// the two need opposite fixes.
  static String lastPlayerUrl = '';
  static final List<String> _events = <String>[];

  @visibleForTesting
  static List<String> get events => List<String>.unmodifiable(_events);

  @visibleForTesting
  static void clear() => _events.clear();

  /// Appends one observation. `details` values are flattened into `k=v` pairs;
  /// long bodies are truncated so the file stays readable. [limit] raises that
  /// bound for values whose tail carries the answer, such as the player's last
  /// attempted URL.
  static void record(
    String stage, [
    Map<String, Object?> details = const <String, Object?> {},
    int limit = 180,
  ]) {
    final stamp = DateTime.now().toIso8601String();
    final buffer = StringBuffer('$stamp  $stage');
    details.forEach((key, value) {
      final text = _shorten(value, limit);
      if (text.isEmpty) return;
      buffer.write('  $key=$text');
    });
    _events.add(buffer.toString());
    if (_events.length > _capacity) _events.removeAt(0);
    CoreLog.w('douyu: $buffer');
  }

  static String _shorten(Object? value, int limit) {
    if (value == null) return '';
    final text = value.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
    return text.length <= limit ? text : '${text.substring(0, limit)}…';
  }

  /// Reads the first bytes of [url] the way the app itself would.
  static Future<void> probeUrl(String url) async {
    if (url.isEmpty) return;
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 8);
    try {
      final request = await client.getUrl(Uri.parse(url));
      request.headers.set(HttpHeaders.userAgentHeader, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)');
      final response = await request.close().timeout(const Duration(seconds: 10));
      var bytes = 0;
      await for (final chunk in response.timeout(const Duration(seconds: 10))) {
        bytes += chunk.length;
        if (bytes >= 64 * 1024) break;
      }
      record('url-probe', <String, Object?>{
        'status': response.statusCode,
        'type': response.headers.contentType,
        'bytes': bytes,
      });
    } catch (error) {
      record('url-probe-failed', <String, Object?>{'error': error});
    } finally {
      client.close(force: true);
    }
  }

  static String dump() => _events.isEmpty ? 'no douyu events recorded' : _events.join('\n');

  /// Writes the buffer next to the app documents so it can be pulled off the
  /// device (iOS Files app) or out of the portable folder on Windows.
  static Future<String?> flushToDisk({Directory? directory}) async {
    try {
      final dir = directory ?? await getApplicationDocumentsDirectory();
      final file = File('${dir.path}${Platform.pathSeparator}douyu_diagnose.txt');
      await file.writeAsString(
        'PureLive douyu diagnostics\n'
        'platform=${Platform.operatingSystem}\n'
        'written=${DateTime.now().toIso8601String()}\n'
        '\n'
        '${dump()}\n',
        flush: true,
      );
      return file.path;
    } catch (error) {
      CoreLog.w('douyu: diagnostics flush failed: $error');
      return null;
    }
  }
}
