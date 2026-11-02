import 'package:flutter/material.dart';

/// One entry of the floating side bar: an icon, its selected twin and a label.
class DuoSideBarEntry {
  const DuoSideBarEntry({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final VoidCallback onTap;
  final bool selected;
}

/// The side navigation iPhone Duo apps get.
///
/// Shape hierarchy follows the system's own vertical UI on this device: each
/// secondary action is its own floating circle, and the primary destinations
/// share one short capsule so the grouping is expressed by shape instead of a
/// divider. Colour stays inside the app's Material 3 language while the
/// selected destination uses a saturated primary fill, which is what makes the
/// current section readable against a near-black background.
///
/// Placement follows the Duo guidance: inset from the hardware edge (the cover
/// camera axis), vertically centred, never mirrored by text direction.
class DuoSideBar extends StatelessWidget {
  const DuoSideBar({
    super.key,
    required this.actions,
    required this.destinations,
    this.leading,
    this.onRight = true,
    this.width = 76,
  });

  /// Secondary actions. Rendered as their own floating circles above the
  /// capsule, the way the system splits its vertical bar into groups.
  final List<DuoSideBarEntry> actions;

  /// Primary destinations, sharing one capsule.
  final List<DuoSideBarEntry> destinations;

  /// Optional first slot for a widget-driven control (the menu button owns its
  /// own popup, so it cannot be expressed as a [DuoSideBarEntry]).
  final Widget? leading;

  /// Which edge the bar floats on. The Duo guidance anchors this to the
  /// hardware (cover camera axis) and to the app's outer edge in split view,
  /// so the caller passes the answer instead of relying on text direction.
  final bool onRight;

  /// Width of the gutter the bar floats in; content starts after it.
  final double width;

  static const double _edgeInset = 16;
  static const double _buttonSize = 44;
  static const double _capsuleWidth = 60;

  /// Stable key so tests can assert the destinations share one capsule.
  static const Key capsuleKey = Key('duo-side-capsule');

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: SafeArea(
        right: false,
        child: Align(
          alignment: onRight ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: onRight ? 0 : _edgeInset, right: onRight ? _edgeInset : 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (leading != null) _DuoFloatingCircle(size: _buttonSize, child: leading),
                for (final action in actions) _DuoFloatingCircle(entry: action),
                if (leading != null || actions.isNotEmpty) const SizedBox(height: 12),
                if (destinations.isNotEmpty) _DuoCapsule(entries: destinations),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Standalone circular button: the shape the system gives secondary actions.
class _DuoFloatingCircle extends StatelessWidget {
  const _DuoFloatingCircle({this.entry, this.size = 44, this.child});

  final DuoSideBarEntry? entry;
  final double size;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final content =
        child ??
        Icon(entry!.selected ? entry!.selectedIcon : entry!.icon, size: 22, color: colors.onSurfaceVariant);

    final button = Material(
      color: colors.surfaceContainerHigh,
      elevation: 3,
      shadowColor: Colors.black54,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: entry?.onTap,
        child: SizedBox.square(
          dimension: size,
          child: Center(child: IconTheme(data: IconThemeData(size: 22, color: colors.onSurfaceVariant), child: content)),
        ),
      ),
    );

    if (entry == null) return Padding(padding: const EdgeInsets.only(bottom: 10), child: button);

    return _SemanticEntry(
      entry: entry!,
      child: Padding(padding: const EdgeInsets.only(bottom: 10), child: button),
    );
  }
}

/// One short capsule holding the primary destinations.
class _DuoCapsule extends StatelessWidget {
  const _DuoCapsule({required this.entries});

  final List<DuoSideBarEntry> entries;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      key: DuoSideBar.capsuleKey,
      color: colors.surfaceContainerHigh,
      elevation: 3,
      shadowColor: Colors.black54,
      borderRadius: BorderRadius.circular(30),
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: DuoSideBar._capsuleWidth,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5), width: 0.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final entry in entries)
              _SemanticEntry(
                entry: entry,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Material(
                    // Saturated fill for the active destination: a tonal
                    // container is invisible against this app's near-black
                    // surfaces.
                    color: entry.selected ? colors.primary : Colors.transparent,
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: entry.onTap,
                      child: SizedBox.square(
                        dimension: 40,
                        child: Icon(
                          entry.selected ? entry.selectedIcon : entry.icon,
                          size: 22,
                          color: entry.selected ? colors.onPrimary : colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SemanticEntry extends StatelessWidget {
  const _SemanticEntry({required this.entry, required this.child});

  final DuoSideBarEntry entry;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: entry.selected,
      label: entry.label,
      child: Tooltip(
        message: entry.label,
        waitDuration: const Duration(milliseconds: 500),
        preferBelow: false,
        child: child,
      ),
    );
  }
}
