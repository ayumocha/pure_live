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
  static final List<String> _events = <String>[];

  @visibleForTesting
  static List<String> get events => List<String>.unmodifiable(_events);

  @visibleForTesting
  static void clear() => _events.clear();

  /// Appends one observation. `details` values are flattened into `k=v` pairs;
  /// long bodies are truncated so the file stays readable.
  static void record(String stage, [Map<String, Object?> details = const <String, Object?>{}]) {
    final stamp = DateTime.now().toIso8601String();
    final buffer = StringBuffer('$stamp  $stage');
    details.forEach((key, value) {
      final text = _shorten(value);
      if (text.isEmpty) return;
      buffer.write('  $key=$text');
    });
    _events.add(buffer.toString());
    if (_events.length > _capacity) _events.removeAt(0);
    CoreLog.w('douyu: $buffer');
  }

  static String _shorten(Object? value) {
    if (value == null) return '';
    final text = value.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
    return text.length <= 180 ? text : '${text.substring(0, 180)}…';
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
