import 'package:flutter/foundation.dart' show TargetPlatform, debugDefaultTargetPlatformOverride;
import 'package:flutter/widgets.dart' show EdgeInsets, Size;
import 'package:flutter_test/flutter_test.dart';
import 'package:pure_live/core/layout/home_layout.dart';

void main() {
  group('iPhone Duo 侧边导航', () {
    tearDown(() {
      debugDefaultTargetPlatformOverride = null;
    });

    test('内屏与外屏都用侧边栏，普通 iPhone 保持底部栏', () {
      // Duo 外屏（约 534×777）：比任何 iPhone 都宽而矮，HIG 把控件放到侧边。
      expect(HomeLayout.useSideNavigation(const Size(534, 777)), isTrue);
      // Duo 内屏横向（约 770×541）。
      expect(HomeLayout.useSideNavigation(const Size(770, 541)), isTrue);
      // Duo 内屏竖向（约 770×1083）也用侧栏，避免开合时控件换边。
      expect(HomeLayout.useSideNavigation(const Size(770, 1083)), isTrue);
      // 普通 iPhone 竖屏（393×852）保持底部栏。
      expect(HomeLayout.useSideNavigation(const Size(393, 852)), isFalse);
      // 小屏手机（375×667）同上。
      expect(HomeLayout.useSideNavigation(const Size(375, 667)), isFalse);
    });

    test('窗口在开合过程中变大时不会在两个壳之间抖动', () {
      // 折叠区域只改变可用尺寸；一旦跨过短宽阈值就稳定停在侧栏。
      const cover = Size(534, 777);
      const inner = Size(770, 541);
      expect(HomeLayout.useSideNavigation(cover), HomeLayout.useSideNavigation(inner));
    });
  });

  group('侧栏在哪一侧（硬件参照，不看语言方向）', () {
    test('外屏摄像头在右上角，镜像与分屏外的默认都是右侧', () {
      // 安全区对称（整屏）→ 右侧。
      expect(HomeLayout.sideBarOnRight(const EdgeInsets.only(top: 47, bottom: 34)), isTrue);
      // 左内边距明显更大 → 这一侧才是设备外缘 → 左侧。
      expect(HomeLayout.sideBarOnRight(const EdgeInsets.only(top: 47, bottom: 34, left: 62)), isFalse);
      // 差在阈值内仍按右侧，避免开合过程中来回跳。
      expect(HomeLayout.sideBarOnRight(const EdgeInsets.only(top: 47, left: 6)), isTrue);
    });
  });
  group('偶数网格列', () {
    tearDown(() {
      debugDefaultTargetPlatformOverride = null;
    });

    test('iOS 上奇数列下取偶数，避免列压在折叠区上', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      expect(HomeLayout.evenColumnsForFold(3), 2);
      expect(HomeLayout.evenColumnsForFold(5), 4);
      expect(HomeLayout.evenColumnsForFold(7), 6);
      expect(HomeLayout.evenColumnsForFold(9), 8);
      // 已经是偶数的保持不变。
      expect(HomeLayout.evenColumnsForFold(2), 2);
      expect(HomeLayout.evenColumnsForFold(4), 4);
    });

    test('其他平台保持原有密度', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      expect(HomeLayout.evenColumnsForFold(3), 3);
      expect(HomeLayout.evenColumnsForFold(5), 5);
    });
  });
}
