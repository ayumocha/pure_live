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

/// The side navigation iPhone Duo apps get: a floating, inset capsule instead
/// of a rail that spans the whole height.
///
/// Shape and colour stay inside the app's own Material 3 language — a
/// `surfaceContainerHigh` capsule with elevation and a Material state layer on
/// each 40dp circular button — rather than the system's glass style, so the bar
/// belongs to this app instead of looking borrowed. Placement follows the Duo
/// guidance: inset from the leading edge, vertically centred, actions grouped
/// above the tab destinations, no full-height rail, icons carrying tooltips and
/// semantics instead of permanent labels, and a fixed gutter so the content
/// grid never shifts between the two displays.
class DuoSideBar extends StatelessWidget {
  const DuoSideBar({
    super.key,
    required this.actions,
    required this.destinations,
    this.leading,
    this.onRight = true,
    this.width = 72,
  });

  /// Toolbar-like actions (multiview, toolbox, search). Rendered above the
  /// destinations, matching the Duo order of navigation controls first.
  final List<DuoSideBarEntry> actions;

  /// Tab destinations (favorites, popular, areas, record).
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

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final bool hasActions = leading != null || actions.isNotEmpty;

    return SizedBox(
      width: width,
      child: SafeArea(
        right: false,
        child: Align(
          alignment: onRight ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: onRight ? 0 : 8, right: onRight ? 8 : 0),
            child: Material(
              color: colors.surfaceContainerHigh,
              elevation: 3,
              shadowColor: Colors.black54,
              borderRadius: BorderRadius.circular(28),
              clipBehavior: Clip.antiAlias,
              child: Container(
                width: 56,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5), width: 0.5),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (leading != null)
                      SizedBox.square(
                        dimension: 40,
                        child: IconTheme(
                          data: IconThemeData(size: 22, color: colors.onSurfaceVariant),
                          child: Center(child: leading),
                        ),
                      ),
                    for (final action in actions) _DuoSideBarButton(entry: action),
                    if (hasActions && destinations.isNotEmpty)
                      _DuoSideBarGroupGap(color: colors.outlineVariant),
                    for (final destination in destinations) _DuoSideBarButton(entry: destination),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Material 3 separates groups with a hairline rather than padding alone.
class _DuoSideBarGroupGap extends StatelessWidget {
  const _DuoSideBarGroupGap({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: SizedBox(width: 24, child: Divider(height: 1, thickness: 1, color: color.withValues(alpha: 0.6))),
    );
  }
}

class _DuoSideBarButton extends StatelessWidget {
  const _DuoSideBarButton({required this.entry});

  final DuoSideBarEntry entry;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Semantics(
        button: true,
        selected: entry.selected,
        label: entry.label,
        child: Tooltip(
          message: entry.label,
          waitDuration: const Duration(milliseconds: 500),
          preferBelow: false,
          child: Material(
            color: entry.selected ? colors.secondaryContainer : Colors.transparent,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: entry.onTap,
              child: SizedBox(
                width: 40,
                height: 40,
                child: Icon(
                  entry.selected ? entry.selectedIcon : entry.icon,
                  size: 22,
                  color: entry.selected ? colors.onSecondaryContainer : colors.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
