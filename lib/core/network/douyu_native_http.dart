import 'dart:convert';
import 'dart:io';

import 'package:cupertino_http/cupertino_http.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pure_live/core/logging/core_log.dart';

/// Sends Douyu's handshake and play requests through the platform HTTP stack.
///
/// Douyu's edge rejects this app when the request comes from `dart:io`: the
/// encryption endpoint answers a bare 400 with an empty body while the same
/// URL, headers and device id from curl are accepted, and the room detail API
/// keeps working. That is a client-fingerprint block, not an API error, so the
/// fix is to present the fingerprint the platform already has: NSURLSession on
/// iOS/macOS via `cupertino_http`.
///
/// Only the two requests that the block breaks go through here — the signature
/// key and the play URL. Everything else keeps using the shared client, whose
/// cookie, proxy and timeout behaviour the rest of the app depends on.
class DouyuNativeHttp {
  DouyuNativeHttp._();

  static http.Client? _cached;

  /// Test seam: a fake client, or `null` to fall back to `dart:io`.
  @visibleForTesting
  static http.Client? debugClientOverride;

  /// Test seam: pretend the platform has no native stack.
  @visibleForTesting
  static bool debugDisable = false;

  static bool get isSupported => !debugDisable && (Platform.isIOS || Platform.isMacOS);

  static http.Client? get _client {
    // The injected client stands in for a platform that has a native stack, so
    // it is consulted before the platform gate.
    final override = debugClientOverride;
    if (override != null) return override;
    if (!isSupported) return null;

    try {
      return _cached ??= CupertinoClient.defaultSessionConfiguration();
    } catch (error) {
      CoreLog.w('Douyu native HTTP client unavailable: $error');
      return null;
    }
  }

  /// GET returning decoded JSON, or `null` when this platform has no native
  /// stack (the caller then keeps its existing path).
  static Future<Object?> getJson(
    String url, {
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 15),
  }) async {
    final client = _client;
    if (client == null) return null;

    final uri = Uri.parse(url).replace(queryParameters: queryParameters);
    final response = await client.get(uri, headers: headers).timeout(timeout);
    return decode(response);
  }

  /// POST of a urlencoded form returning decoded JSON, or `null` when this
  /// platform has no native stack.
  static Future<Object?> postFormJson(
    String url, {
    required String body,
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 15),
  }) async {
    final client = _client;
    if (client == null) return null;

    final merged = <String, String>{'content-type': 'application/x-www-form-urlencoded', ...?headers};
    final response = await client.post(Uri.parse(url), headers: merged, body: body).timeout(timeout);
    return decode(response);
  }

  /// GET returning the raw body and the cookies the response set, used to adopt
  /// the device id Douyu issues.
  static Future<DouyuNativeFetch?> getWithCookies(
    String url, {
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 15),
  }) async {
    final client = _client;
    if (client == null) return null;

    final response = await client.get(Uri.parse(url), headers: headers).timeout(timeout);
    final raw = response.headers['set-cookie'];
    return DouyuNativeFetch(
      statusCode: response.statusCode,
      body: response.body,
      setCookies: raw == null || raw.isEmpty ? const <String>[] : splitSetCookies(raw),
    );
  }

  /// `package:http` joins repeated `set-cookie` headers with `, ` while an
  /// `Expires` attribute also contains a comma, so split on the cookie start
  /// that follows a comma instead of on every comma.
  @visibleForTesting
  static List<String> splitSetCookies(String header) {
    final result = <String>[];
    final parts = header.split(RegExp(r',\s*(?=[A-Za-z0-9_\-]+=)'));
    for (final part in parts) {
      final value = part.trim();
      if (value.isNotEmpty) result.add(value);
    }
    return result;
  }

  /// Decodes the body the way the app's other Douyu calls expect: JSON when the
  /// server says so, otherwise the raw string.
  @visibleForTesting
  static Object? decode(http.Response response) {
    final body = response.body;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw DouyuNativeHttpException(response.statusCode, body);
    }
    if (body.isEmpty) return null;

    try {
      return json.decode(body);
    } on FormatException {
      return body;
    }
  }

  @visibleForTesting
  static void debugReset() {
    _cached = null;
    debugClientOverride = null;
    debugDisable = false;
  }
}

class DouyuNativeFetch {
  const DouyuNativeFetch({required this.statusCode, required this.body, required this.setCookies});

  final int statusCode;
  final String body;
  final List<String> setCookies;
}

class DouyuNativeHttpException implements Exception {
  const DouyuNativeHttpException(this.statusCode, this.body);

  final int statusCode;
  final String body;

  @override
  String toString() => 'DouyuNativeHttpException($statusCode)';
}
