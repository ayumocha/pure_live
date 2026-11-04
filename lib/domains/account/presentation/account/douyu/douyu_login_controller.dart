import 'dart:async';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:pure_live/core/index.dart';
import 'package:pure_live/core/config/cookie_settings_controller.dart';
import 'package:pure_live/core/logging/core_log.dart';
import 'package:pure_live/core/network/douyu_login_cookies.dart';
import 'package:pure_live/core/network/douyu_utils.dart';

/// Signs in to Douyu inside the app and keeps the renewable half of the cookie.
///
/// The viewer never sees a cookie string: the H5 page does the login, and the
/// session (`acf_jwt_token`), the renewal key (`LTP0`) and the device id
/// (`dy_did`) are read straight out of the WebView. Renewal then runs on the
/// existing `DouyuUtils.ensureFreshSession` path, so a login survives past the
/// seven days a pasted web cookie lasts.
class DouyuLoginController extends GetxController {
  /// The H5 site, deliberately: only it issues `LTP0`, and without that key the
  /// app can only ask the viewer to log in again every week.
  static const String loginUrl = 'https://m.douyu.com/';

  final RxBool isSaving = false.obs;
  final RxString errorMessageKey = ''.obs;

  Future<void>? _activeRead;

  /// Reads the current cookies. With [quiet] set, a page that simply has no
  /// login yet stays silent, which is what the automatic path needs on every
  /// page load.
  Future<bool> readCookies({WebUri? url, bool quiet = false}) {
    final active = _activeRead;
    if (active != null) return active.then((_) => false);

    late final Future<bool> task;
    task = _read(url: url, quiet: quiet).whenComplete(() {
      if (identical(_activeRead, task)) _activeRead = null;
    });
    _activeRead = task;
    return task;
  }

  Future<bool> _read({WebUri? url, required bool quiet}) async {
    if (isSaving.value) return false;
    isSaving.value = true;
    if (!quiet) errorMessageKey.value = '';

    try {
      final cookies = await CookieManager.instance().getCookies(url: url ?? WebUri(loginUrl));
      final parsed = extractDouyuLoginCookies(
        cookies.map((cookie) => DouyuCookieValue(cookie.name, cookie.value)),
      );

      if (parsed == null) {
        if (!quiet) errorMessageKey.value = 'douyu_login_not_ready';
        return false;
      }

      final store = CookieSettingsController.to;
      store.douyuCookie.v = parsed.header;
      store.douyuCookieSavedAt.v = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      store.douyuLtp0.v = parsed.longTerm ?? '';
      store.douyuDid.v = parsed.deviceId ?? '';

      // Proving the long-term key works now is worth one request: it turns a
      // silent expiry seven days later into a definite answer today.
      String? renewed;
      if (parsed.isRenewable) {
        try {
          renewed = await DouyuUtils.refreshSession(force: true);
        } catch (error) {
          CoreLog.w('Douyu login renewal after web sign-in failed: $error');
        }
      }

      ToastUtil.show(i18n(renewed != null || !parsed.isRenewable ? 'douyu_login_success' : 'douyu_login_saved'));
      await CookieManager.instance().deleteAllCookies();
      Get.back(result: true);
      return true;
    } catch (error) {
      CoreLog.w('Douyu web login failed: $error');
      if (!quiet) errorMessageKey.value = 'douyu_login_failed';
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  /// Called on every page the WebView finishes loading; only commits when a
  /// session is actually present, so browsing the site does not toast anything.
  void onLoadStop(InAppWebViewController _, WebUri? url) {
    unawaited(readCookies(url: url, quiet: true));
  }

  Future<void> readManually() => readCookies(quiet: false);
}
