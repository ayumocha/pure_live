# iPhone Duo 布局适配

依据 Apple 的 *Designing for iPhone Duo*（HIG）与 *Preparing your app for iPhone Duo*：
Duo 是折叠 iPhone，有外屏（更宽更矮，约 534×777 pt）与内屏（常规宽度，约 770×541 / 770×1083 pt）。
HIG 要求：按尺寸类适配、不要把宽度写死；工具栏与标签栏移到**屏幕侧边**（内屏竖屏例外）；
保留区域（外屏摄像头/灵动岛、内屏摄像头、折叠区）要避让；网格用**偶数列**，避免一列压在折叠区；
能并排的内容用分屏视图同时显示两层。

参考：
- <https://developer.apple.com/documentation/technologyoverviews/preparing-your-app-for-iphone-duo>
- <https://developer.apple.com/design/human-interface-guidelines/designing-for-iphone-duo>
- 中文翻译：<https://www.uisdc.com/design-for-iphone-duo>

## 本轮改了什么

| 项 | 之前 | 现在 |
| --- | --- | --- |
| 导航壳形态 | `Get.width > 680` 才用侧栏 | `HomeLayout.useSideNavigation(size)`：常规宽度（≥600pt）**或**短宽窗口（宽/高 > 0.62）都用侧栏 |
| 录制中心入口 | 宽布局被从侧栏剔除，只作为顶部动作图标出现 | 始终作为侧栏目的地，与竖屏底部栏顺序一致 |
| 网格列数 | 2/3/4/5、3/5/7/9 等奇偶混排 | iOS 上走 `HomeLayout.evenColumnsForFold`，奇数列下取偶数（3→2、5→4、7→6、9→8）；其他平台密度不变 |

### 侧栏形态（Material 3，不是系统玻璃）

Duo 上系统把标签栏/工具栏渲染成侧边胶囊，本仓按同一位置规则，但**材质保持自己的 Material 3 语言**，不套 iOS 液态玻璃：

- 不透明 `surfaceContainerHigh` 胶囊，`elevation: 3` + 阴影，圆角 28，`outlineVariant` 半透明描边；
- 每个按钮 40dp 圆形，选中态为 `secondaryContainer` 实心圆 + `onSecondaryContainer` 图标；
- 组间用 1dp `outlineVariant` 细分隔线（M3 的分组方式），不是整条贴边的 rail；
- 只有图标，名称走 Tooltip + Semantics，符合 HIG「提供标题但不常显」；
- 固定 72pt 栏宽，内容永远从栏右侧开始，开合时不跳动。

组件：`lib/features/home/duo_side_bar.dart`；测试：`test/features/home/duo_side_bar_test.dart`（3 项：选中态图标、栏宽、分组与栏内布局）。
代码落点：

- `lib/core/layout/home_layout.dart`：两条规则与注释（放在 `core` 以满足分层约束 `domains -> core`）。
- `lib/features/home/home_page.dart`：壳形态判定、移除「宽布局剔除录制中心」的分支。
- `lib/features/home/tablet_view.dart`：删除重复的顶部录制按钮。
- 网格：`popular_grid_view.dart`、`favorite/room_grid_view.dart`、`history/history_page.dart`、`area_rooms_page.dart`、`areas_grid_view.dart`、`areas/favorite_areas_page.dart`。
- 测试：`test/core/layout/home_layout_test.dart`（4 项）。

## 明确没做（本轮范围外）

- **保留区域 API**：HIG 建议用 `ReservedRegion` / `UIView.ReservedRegion` 把内容移出折叠区与摄像头区；Flutter 侧没有对应接口，本轮用「偶数列 + 安全区」近似规避，没有精确避让。
- **分屏视图（两栏）**：内屏上「列表 + 详情」并排需要改动房间页路由结构，未做。
- **内屏竖屏的横向栏**：HIG 允许内屏竖屏保留横向栏；本仓为「开合时控件不换边」统一用侧栏，属于有意偏离。
- `UIApplicationSupportsMultipleScenes` 仍为 `false`；Duo 的分屏多任务是否需要多场景未验证。

## 怎么在真机上看

1. 折叠状态下看外屏：底部不应再有标签栏，关注/热门/分区/录制中心应在左侧栏，顺序与内屏一致。
2. 展开：控件位置不应跳变，房间卡片不应有某一列压在中间折叠线上。
3. 半折（部分展开）：控件不应被折痕切断；安全区应随可用尺寸变化重新计算。
4. 内屏竖屏（转 90°）：仍是侧栏，这是本轮的取舍。

## 构建

iOS 无本机工具链，走 GitHub Actions 的 macOS runner（`build_pure_live_release.yml`，输入 `build_ios=true`）。
产物为未签名 `Runner.app` 压缩包与 ad-hoc 签名的 TrollStore IPA；IPA 需自行侧载验证。
