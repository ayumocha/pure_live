import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pure_live/features/home/duo_side_bar.dart';

Widget _host(Widget child) => MaterialApp(
  theme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
  home: Scaffold(body: Row(children: [child, const Expanded(child: SizedBox())])),
);

void main() {
  testWidgets('悬浮侧栏渲染出动作与目的地，选中项用选中图标', (tester) async {
    final tapped = <String>[];

    await tester.pumpWidget(
      _host(
        DuoSideBar(
          actions: [
            DuoSideBarEntry(
              icon: Icons.grid_view_outlined,
              selectedIcon: Icons.grid_view,
              label: '多画面',
              onTap: () => tapped.add('多画面'),
            ),
          ],
          destinations: [
            const DuoSideBarEntry(
              icon: Icons.favorite_border,
              selectedIcon: Icons.favorite,
              label: '关注',
              onTap: _noop,
              selected: true,
            ),
            DuoSideBarEntry(
              icon: Icons.local_fire_department_outlined,
              selectedIcon: Icons.local_fire_department,
              label: '热门',
              onTap: () => tapped.add('热门'),
            ),
          ],
        ),
      ),
    );

    expect(find.byIcon(Icons.favorite), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border), findsNothing);
    expect(find.byIcon(Icons.local_fire_department_outlined), findsOneWidget);
    expect(find.byIcon(Icons.grid_view_outlined), findsOneWidget);

    await tester.tap(find.byIcon(Icons.grid_view_outlined));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.local_fire_department_outlined));
    await tester.pump();

    expect(tapped, ['多画面', '热门']);
  });

  testWidgets('侧栏在右侧时贴右边缘，内容整体在它左边', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
        home: Scaffold(
          body: Row(
            children: [
              const Expanded(child: SizedBox()),
              DuoSideBar(
                onRight: true,
                actions: const [],
                destinations: const [
                  DuoSideBarEntry(icon: Icons.favorite, selectedIcon: Icons.favorite, label: '关注', onTap: _noop),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    final screenWidth = tester.getSize(find.byType(Scaffold)).width;
    final barRect = tester.getRect(find.byType(DuoSideBar));
    expect(barRect.right, screenWidth);
  });

  testWidgets('侧栏在左侧时贴左边缘', (tester) async {
    await tester.pumpWidget(
      _host(
        const DuoSideBar(
          onRight: false,
          actions: [],
          destinations: [
            DuoSideBarEntry(icon: Icons.favorite, selectedIcon: Icons.favorite, label: '关注', onTap: _noop),
          ],
        ),
      ),
    );

    final barRect = tester.getRect(find.byType(DuoSideBar));
    expect(barRect.left, 0);
  });
  testWidgets('侧栏只占固定栏宽，内容从栏右侧开始', (tester) async {
    await tester.pumpWidget(_host(const DuoSideBar(actions: [], destinations: [])));

    final barSize = tester.getSize(find.byType(DuoSideBar));
    expect(barSize.width, 72);
  });

  testWidgets('分组之间用细分隔线，且目的地全部在栏内', (tester) async {
    await tester.pumpWidget(
      _host(
        const DuoSideBar(
          actions: [
            DuoSideBarEntry(icon: Icons.search, selectedIcon: Icons.search, label: '搜索', onTap: _noop),
          ],
          destinations: [
            DuoSideBarEntry(icon: Icons.heart_broken, selectedIcon: Icons.favorite, label: '关注', onTap: _noop),
            DuoSideBarEntry(icon: Icons.apps, selectedIcon: Icons.apps, label: '分区', onTap: _noop),
          ],
        ),
      ),
    );

    expect(find.byType(Divider), findsOneWidget);

    final barRect = tester.getRect(find.byType(DuoSideBar));
    for (final icon in [Icons.search, Icons.heart_broken, Icons.apps]) {
      final rect = tester.getRect(find.byIcon(icon));
      expect(rect.left, greaterThanOrEqualTo(barRect.left));
      expect(rect.right, lessThanOrEqualTo(barRect.right));
    }
  });
}

void _noop() {}
