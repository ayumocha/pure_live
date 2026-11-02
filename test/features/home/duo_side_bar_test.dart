import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pure_live/features/home/duo_side_bar.dart';

Widget _host(Widget child) => MaterialApp(
  theme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
  home: Scaffold(body: Row(children: [const Expanded(child: SizedBox()), child])),
);

const _actions = [
  DuoSideBarEntry(icon: Icons.grid_view_outlined, selectedIcon: Icons.grid_view, label: '多画面', onTap: _noop),
  DuoSideBarEntry(icon: Icons.link, selectedIcon: Icons.link, label: '工具箱', onTap: _noop),
];

const _destinations = [
  DuoSideBarEntry(icon: Icons.favorite_border, selectedIcon: Icons.favorite, label: '关注', onTap: _noop, selected: true),
  DuoSideBarEntry(icon: Icons.local_fire_department_outlined, selectedIcon: Icons.local_fire_department, label: '热门', onTap: _noop),
  DuoSideBarEntry(icon: Icons.apps, selectedIcon: Icons.apps, label: '分区', onTap: _noop),
];

void main() {
  testWidgets('动作是独立圆，标签共用一个胶囊', (tester) async {
    await tester.pumpWidget(_host(const DuoSideBar(actions: _actions, destinations: _destinations)));

    final actionRect = tester.getRect(find.byIcon(Icons.grid_view_outlined));
    final tabRect = tester.getRect(find.byIcon(Icons.favorite));

    // 动作在胶囊上方，不进入胶囊；所有标签都在胶囊内部。
    expect(actionRect.bottom, lessThan(tabRect.top));
    final capsule = find.byKey(DuoSideBar.capsuleKey);
    expect(capsule, findsOneWidget);
    for (final icon in [Icons.favorite, Icons.local_fire_department_outlined, Icons.apps]) {
      expect(find.descendant(of: capsule, matching: find.byIcon(icon)), findsOneWidget);
    }
    expect(find.descendant(of: capsule, matching: find.byIcon(Icons.grid_view_outlined)), findsNothing);
  });

  testWidgets('选中项用选中图标，未选中项用线框图标', (tester) async {
    await tester.pumpWidget(_host(const DuoSideBar(actions: _actions, destinations: _destinations)));

    expect(find.byIcon(Icons.favorite), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border), findsNothing);
    expect(find.byIcon(Icons.local_fire_department_outlined), findsOneWidget);
  });

  testWidgets('点击动作与标签都会回调', (tester) async {
    final tapped = <String>[];
    await tester.pumpWidget(
      _host(
        DuoSideBar(
          actions: [
            DuoSideBarEntry(icon: Icons.link, selectedIcon: Icons.link, label: '工具箱', onTap: () => tapped.add('工具箱')),
          ],
          destinations: [
            DuoSideBarEntry(icon: Icons.apps, selectedIcon: Icons.apps, label: '分区', onTap: () => tapped.add('分区')),
          ],
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.link));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.apps));
    await tester.pump();

    expect(tapped, ['工具箱', '分区']);
  });

  testWidgets('没有分隔线：分组靠形状', (tester) async {
    await tester.pumpWidget(_host(const DuoSideBar(actions: _actions, destinations: _destinations)));

    expect(find.byType(Divider), findsNothing);
  });

  testWidgets('默认贴右边缘，onRight=false 时贴左边缘', (tester) async {
    await tester.pumpWidget(_host(const DuoSideBar(actions: _actions, destinations: _destinations)));
    var barRect = tester.getRect(find.byType(DuoSideBar));
    expect(barRect.right, tester.getSize(find.byType(Scaffold)).width);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
        home: const Scaffold(
          body: Row(
            children: [
              DuoSideBar(actions: _actions, destinations: _destinations, onRight: false),
              Expanded(child: SizedBox()),
            ],
          ),
        ),
      ),
    );
    barRect = tester.getRect(find.byType(DuoSideBar));
    expect(barRect.left, 0);
  });
}

void _noop() {}
