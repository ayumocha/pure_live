import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:pure_live/core/index.dart';
import 'package:pure_live/domains/account/presentation/account/douyu/douyu_login_controller.dart';
import 'package:remixicon/remixicon.dart';

/// Douyu sign-in without handling a cookie string.
///
/// The H5 page is loaded here on purpose: it is the flow that hands out the
/// renewable session, and it is what the viewer would use in a browser anyway.
class DouyuLoginPage extends GetView<DouyuLoginController> {
  const DouyuLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(i18n('douyu_login_title')),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Obx(() {
              final busy = controller.isSaving.value;
              return TextButton.icon(
                key: const ValueKey('douyu-web-login-read'),
                onPressed: busy ? null : controller.readManually,
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                  textStyle: const TextStyle(fontWeight: FontWeight.w600),
                ),
                icon: const Icon(Remix.lock_unlock_line, size: 16),
                label: Text(i18n('douyu_login_read')),
              );
            }),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          InAppWebView(
            key: const ValueKey('douyu-web-login-view'),
            initialUrlRequest: URLRequest(url: WebUri(DouyuLoginController.loginUrl)),
            onLoadStop: controller.onLoadStop,
            initialSettings: InAppWebViewSettings(
              // A phone user agent keeps the H5 layout, which is the one the
              // viewer's own browser uses to sign in.
              userAgent:
                  'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) '
                  'AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1',
              useShouldOverrideUrlLoading: false,
              transparentBackground: false,
            ),
          ),
          Obx(() {
            if (!controller.isSaving.value) return const SizedBox.shrink();
            return ColoredBox(
              color: theme.colorScheme.surface.withValues(alpha: 0.9),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(i18n('douyu_login_reading'), style: AppTextStyles.t14),
                  ],
                ),
              ),
            );
          }),
          Obx(() {
            final key = controller.errorMessageKey.value;
            if (key.isEmpty) return const SizedBox.shrink();
            return Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Material(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: theme.colorScheme.onErrorContainer, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            i18n(key),
                            style: AppTextStyles.t13.copyWith(color: theme.colorScheme.onErrorContainer),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Get.toNamed(RoutePath.kDouyuAccountCookie),
                          child: Text(i18n('douyu_login_manual')),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
