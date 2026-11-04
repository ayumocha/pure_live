import 'package:pure_live/core/network/douyu_utils.dart';

/// One cookie as the WebView reports it, without depending on the plugin type.
class DouyuCookieValue {
  const DouyuCookieValue(this.name, this.value);

  final String name;
  final String value;
}

/// What a Douyu H5 login leaves behind, and which parts renewal needs.
///
/// The H5 flow (`m.douyu.com`) is the only one that hands out a renewable
/// session: `acf_jwt_token` is a JWT the server can re-issue, and `LTP0` is the
/// long-term key that re-issues it. The web flow (`www.douyu.com`) only sets
/// `dy_auth`, which is opaque, lasts about seven days and cannot be renewed —
/// which is exactly why signing in through the H5 page is worth doing.
class DouyuLoginCookies {
  const DouyuLoginCookies({
    required this.header,
    required this.sessionToken,
    required this.longTerm,
    required this.deviceId,
  });

  /// The whole `m.douyu.com` cookie set as one `Cookie:` header value.
  final String header;

  /// `acf_jwt_token` (preferred) or `acf_auth`.
  final String? sessionToken;

  /// `LTP0`, the key the passport endpoint renews with.
  final String? longTerm;

  /// `dy_did`, the device the login belongs to.
  final String? deviceId;

  bool get hasSession => sessionToken != null;

  /// Whether `refreshSession` can keep this login alive without the viewer.
  bool get isRenewable => longTerm != null && deviceId != null;
}

/// Reads a WebView cookie set, or `null` when there is no login in it yet.
DouyuLoginCookies? extractDouyuLoginCookies(Iterable<DouyuCookieValue> cookies) {
  String? jwt;
  String? auth;
  String? longTerm;
  String? deviceId;
  final fields = <String>[];

  for (final cookie in cookies) {
    final name = cookie.name.trim();
    final value = cookie.value.trim();
    if (name.isEmpty || value.isEmpty) continue;

    fields.add('$name=$value');
    switch (name) {
      case DouyuUtils.jwtTokenName:
        jwt = value;
      case DouyuUtils.authTokenName:
        auth = value;
      case DouyuUtils.longTermTokenName:
        longTerm = value;
      case DouyuUtils.deviceIdName:
        deviceId = value;
    }
  }

  final sessionToken = jwt ?? auth;
  if (sessionToken == null || fields.isEmpty) return null;

  return DouyuLoginCookies(
    header: fields.join('; '),
    sessionToken: sessionToken,
    longTerm: longTerm,
    deviceId: deviceId,
  );
}
