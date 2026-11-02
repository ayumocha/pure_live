import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform;
import 'package:remixicon/remixicon.dart';
import 'package:pure_live/core/index.dart';
import 'package:pure_live/core/consts/app_consts.dart';
import 'package:pure_live/features/home/duo_side_bar.dart';

class HomeTabletView extends StatelessWidget {
  final Widget body;
  final int index;
  final List<String> activeMenuIds;
  final void Function(int) onDestinationSelected;

  const HomeTabletView({
    super.key,
    required this.body,
    required this.index,
    required this.activeMenuIds,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Builder(
          builder: (context) {
            final List<NavigationRailDestination> destinations = [];
            final List<DuoSideBarEntry> duoDestinations = [];
            final List<int> virtualToRealMap = [];

            for (String id in activeMenuIds) {
              final menu = HomeMenu.fromId(id);
              if (menu != null) {
                virtualToRealMap.add(menu.index);

                switch (menu) {
                  case HomeMenu.favorites:
                    destinations.add(
                      NavigationRailDestination(
                        icon: const Icon(Remix.heart_3_line),
                        selectedIcon: const Icon(Remix.heart_3_fill),
                        label: Text(i18n('favorites_title')),
                      ),
                    );
                    duoDestinations.add(
                      DuoSideBarEntry(
                        icon: Remix.heart_3_line,
                        selectedIcon: Remix.heart_3_fill,
                        label: i18n('favorites_title'),
                        selected: index == menu.index,
                        onTap: () => onDestinationSelected(menu.index),
                      ),
                    );
                    break;
                  case HomeMenu.popular:
                    destinations.add(
                      NavigationRailDestination(
                        icon: const Icon(Remix.fire_line),
                        selectedIcon: const Icon(Remix.fire_fill),
                        label: Text(i18n('popular_title')),
                      ),
                    );
                    duoDestinations.add(
                      DuoSideBarEntry(
                        icon: Remix.fire_line,
                        selectedIcon: Remix.fire_fill,
                        label: i18n('popular_title'),
                        selected: index == menu.index,
                        onTap: () => onDestinationSelected(menu.index),
                      ),
                    );
                    break;
                  case HomeMenu.areas:
                    destinations.add(
                      NavigationRailDestination(
                        icon: const Icon(Remix.apps_2_line),
                        selectedIcon: const Icon(Remix.apps_2_fill),
                        label: Text(i18n('areas_title')),
                      ),
                    );
                    duoDestinations.add(
                      DuoSideBarEntry(
                        icon: Remix.apps_2_line,
                        selectedIcon: Remix.apps_2_fill,
                        label: i18n('areas_title'),
                        selected: index == menu.index,
                        onTap: () => onDestinationSelected(menu.index),
                      ),
                    );
                    break;
                  case HomeMenu.record:
                    destinations.add(
                      NavigationRailDestination(
                        icon: const Icon(Remix.download_2_line),
                        selectedIcon: const Icon(Remix.download_2_fill),
                        label: Text(i18n('record_center')),
                      ),
                    );
                    duoDestinations.add(
                      DuoSideBarEntry(
                        icon: Remix.download_2_line,
                        selectedIcon: Remix.download_2_fill,
                        label: i18n('record_center'),
                        selected: index == menu.index,
                        onTap: () => onDestinationSelected(menu.index),
                      ),
                    );
                    break;
                }
              }
            }

            int? activeSelectedIndex;
            final pos = virtualToRealMap.indexOf(index);
            if (pos >= 0 && pos < destinations.length) {
              activeSelectedIndex = pos;
            } else {
              activeSelectedIndex = null;
            }

            final Widget content = destinations.isEmpty
                ? AppStatusView(
                    type: AppStatusType.empty,
                    icon: Remix.menu_2_fill,
                    title: i18n('no_menu_title'),
                    subtitle: i18n('no_menu_subtitle'),
                  )
                : body;

            // iPhone Duo draws bar controls as a floating capsule of circular
            // buttons rather than a full-height material rail with a divider.
            // iOS gets that shape; desktop keeps the rail it already uses.
            if (defaultTargetPlatform == TargetPlatform.iOS) {
              return Obx(
                () => Row(
                  children: [
                    DuoSideBar(
                      leading: const MenuButton(),
                      actions: [
                        if (SettingsService.to.app.enableMultiView.v)
                          DuoSideBarEntry(
                            icon: Remix.layout_grid_line,
                            selectedIcon: Remix.layout_grid_line,
                            label: i18n('multiview_title'),
                            onTap: AppNavigator.toMultiview,
                          ),
                        DuoSideBarEntry(
                          icon: Remix.link,
                          selectedIcon: Remix.link,
                          label: i18n('toolbox_title'),
                          onTap: () => Get.toNamed(RoutePath.kToolbox),
                        ),
                        DuoSideBarEntry(
                          icon: CustomIcons.search,
                          selectedIcon: CustomIcons.search,
                          label: i18n('search_live'),
                          onTap: () => Get.toNamed(RoutePath.kSearch),
                        ),
                      ],
                      destinations: duoDestinations,
                    ),
                    Expanded(child: content),
                  ],
                ),
              );
            }

            return Row(
              children: [
                NavigationRail(
                  groupAlignment: 0.9,
                  labelType: NavigationRailLabelType.all,
                  leading: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Padding(padding: EdgeInsets.all(12), child: MenuButton()),
                      Obx(
                        () => SettingsService.to.app.enableMultiView.v
                            ? Padding(
                                padding: const EdgeInsets.only(top: 0, bottom: 12, left: 12, right: 12),
                                child: IconButton(
                                  onPressed: AppNavigator.toMultiview,
                                  tooltip: i18n('multiview_title'),
                                  icon: const Icon(Remix.layout_grid_line),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 0, bottom: 12, left: 12, right: 12),
                        child: IconButton(
                          onPressed: () => Get.toNamed(RoutePath.kToolbox),
                          icon: const Icon(Remix.link),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 0, bottom: 12, left: 12, right: 12),
                        child: IconButton(
                          onPressed: () => Get.toNamed(RoutePath.kSearch),
                          icon: const Icon(CustomIcons.search),
                        ),
                      ),
                    ],
                  ),
                  destinations: destinations,
                  selectedIndex: activeSelectedIndex,
                  onDestinationSelected: (int virtualIndex) {
                    if (virtualIndex >= 0 && virtualIndex < virtualToRealMap.length) {
                      onDestinationSelected(virtualToRealMap[virtualIndex]);
                    }
                  },
                ),
                const VerticalDivider(width: 1),
                Expanded(child: content),
              ],
            );
          },
        ),
      ),
    );
  }
}
