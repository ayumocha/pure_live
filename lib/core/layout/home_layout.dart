import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/widgets.dart' show Size;

/// Layout decisions for the home shell that differ from a plain phone.
///
/// Apple's foldable iPhone (Duo) has two displays: a cover screen that is
/// wider and shorter than any other iPhone, and a regular-width inner display.
/// The Human Interface Guidelines move toolbars and tab bars to the screen
/// edge on both, so content keeps its vertical space and the controls stay in
/// the same place when the device opens or closes. A bare `width > 680`
/// threshold misses the cover screen (about 534×777 points), so the rule below
/// also treats a short-wide window as side-navigated.
abstract final class HomeLayout {
  const HomeLayout._();

  /// Compact-width windows at or above this width use the side rail.
  static const double sideNavigationWidth = 600;

  /// A window whose width/height ratio is above this is "short and wide" even
  /// though it is narrower than [sideNavigationWidth]. The Duo cover screen is
  /// 534/777 ≈ 0.69; a classic phone is 393/852 ≈ 0.46.
  static const double shortWideRatio = 0.62;

  /// Whether the home shell should navigate from a leading rail instead of a
  /// bottom bar.
  ///
  /// Deviation from the HIG, on purpose: the inner display in portrait is
  /// regular width and the HIG would keep horizontal bars there, but moving
  /// the entries between the two displays is exactly the "controls jumped far
  /// away" problem the same guidance warns about, so the rail stays.
  static bool useSideNavigation(Size size) {
    if (size.width >= sideNavigationWidth) return true;

    return size.width > size.height * shortWideRatio;
  }

  /// Keeps a grid's column count even so no column of cards straddles the
  /// fold. The HIG asks for even columns on foldable screens; other platforms
  /// keep their existing density.
  static int evenColumnsForFold(int columns) {
    if (defaultTargetPlatform != TargetPlatform.iOS) return columns;
    if (columns.isEven) return columns;

    return columns >= 5 ? columns - 1 : 2;
  }
}
