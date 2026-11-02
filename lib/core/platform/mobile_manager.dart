import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pure_live/core/platform/platform_utils.dart';

class MobileManager {
  static Future<void> initialize() async {
    if (!PlatformUtils.isMobile) return;

    try {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent, systemNavigationBarColor: Colors.transparent),
      );

      if (Platform.isIOS) {
        await _initializeIOS();
      }

      if (Platform.isAndroid) {
        await _initializeAndroid();
      }
    } catch (e) {
      debugPrint('移动端初始化失败: $e');
    }
  }

  static Future<void> _initializeIOS() async {
    try {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.dark,
          statusBarColor: Colors.transparent,
        ),
      );
    } catch (e) {
      debugPrint('iOS 初始化失败: $e');
    }
  }

  static Future<void> _initializeAndroid() async {
    try {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarDividerColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      );

      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } catch (e) {
      debugPrint('Android 初始化失败: $e');
    }
  }

  static void setStatusBarStyle({required bool isDarkTheme}) {
    if (!PlatformUtils.isMobile) return;

    try {
      if (Platform.isIOS) {
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarBrightness: isDarkTheme ? Brightness.dark : Brightness.light,
            statusBarIconBrightness: isDarkTheme ? Brightness.light : Brightness.dark,
            statusBarColor: Colors.transparent,
          ),
        );
      } else if (Platform.isAndroid) {
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.transparent,
            statusBarIconBrightness: isDarkTheme ? Brightness.light : Brightness.dark,
            systemNavigationBarIconBrightness: isDarkTheme ? Brightness.light : Brightness.dark,
          ),
        );
      }
    } catch (e) {
      debugPrint('状态栏样式设置失败: $e');
    }
  }

  /// Hides the system chrome while a playback route is open.
  ///
  /// On Duo the status bar shares the screen edge with the app's own vertical
  /// controls, so a room spends that edge on a clock and a battery icon for no
  /// reason. Only iOS changes behaviour: Android already runs edge-to-edge and
  /// its bars are transparent, so hiding them there would remove reachable
  /// controls instead of freeing space.
  static Future<void> enterImmersivePlayback() async {
    if (!PlatformUtils.isMobile || !Platform.isIOS) return;

    try {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: const <SystemUiOverlay>[]);
    } catch (e) {
      debugPrint('隐藏状态栏失败: $e');
    }
  }

  /// Restores the chrome the rest of the app expects after a room closes.
  static Future<void> exitImmersivePlayback() async {
    if (!PlatformUtils.isMobile || !Platform.isIOS) return;

    try {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      await _initializeIOS();
    } catch (e) {
      debugPrint('恢复状态栏失败: $e');
    }
  }}
