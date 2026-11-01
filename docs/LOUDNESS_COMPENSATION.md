# 响度补偿（volume-gain）

本仓在整体并入上游主干后唯一保留的自定义功能。上游没有对应实现（`git grep -l loudness upstream/master -- lib` 为空），因此它是一条独立的功能线，不是上游补丁。

## 行为

四档：关闭（0 dB，默认）、轻度（+3 dB）、标准（+6 dB）、强力（+9 dB）。

- 只写 mpv 的 `volume-gain` 一个属性，作用于**源**而不是输出：用户的音量、静音、音轨选择与画质全部保持独立。
- 关闭档写 `0`，这就是"关掉即还原"的实现方式，不依赖重建播放器。
- 多画面、全屏、画中画共用同一份设置，因为属性在每次 open 和 rebuild 时都会重新带上。

## 落点（并入上游后的新接线）

| 位置 | 作用 |
| --- | --- |
| `lib/core/player/kernel/loudness_compensation.dart` | 档位枚举、增益表、属性映射、拒绝判定、`LoudnessCompensation.applyTo` |
| `lib/core/player/kernel/media_kit_live_properties.dart` | `applyLoudnessCompensation` 在 `beforeOpen` 里、首个 `loadfile` 之前写属性；不放进装配表 `build()`，因为那张表的写入与按源属性抢同一个键 |
| `lib/core/config/player_settings_controller.dart` | 设置键 `loudnessCompensation`（Hive，默认 `off`），以及独立的 `loudnessCompensationDispatcher` |
| `lib/core/player/kernel/player_kernel_service.dart` | 把设置变更接到当前播放句柄，调用 `applyTo` |
| `lib/features/settings/pages/player_loudness_page.dart` | 四档选择页；被拒时显示实际原因 |

## 失败处置

`PlayerHandle.applyEngineOptions` 返回 `EngineOptionReport`，本功能只关心自己那一个属性：

- `appliedLive` / `stagedForNextOpen` / `rebuiltFor` → 视为已接受；
- `unsupported` 里出现 `volume-gain` → 记进 `LoudnessCompensation.lastError`，设置页显示"当前播放内核不接受该属性"，**不进入播放器的错误/重连路径**；
- 调用本身抛错 → 同样只记录，不抛出。

应用时固定使用 `EngineOptionEffect.nextOpen`：一次增益调整永远不值得为它重建引擎，当前实例接不了就等下一次 open。

## 迁移与默认值

- 键缺失（本功能之前的旧安装）→ `off`，升级不会改动任何人的音量。
- 陌生/空字符串 → `off`，不会因为残留脏值突然放大音量。
- 该键走通用 Hive 持久化与备份/恢复路径，无需单独迁移代码。

## 验证

```powershell
.\tool\flutterw.ps1 test --no-pub test/core/player/loudness_compensation_test.dart
```

覆盖：档位还原、增益表、属性与选项格式、`unsupported` 与 `stagedForNextOpen` 的判定、文案键唯一性、缺键默认值与跨实例持久化。

未覆盖：真实房间里的听感与削波。`volume-gain` 是否被具体 libmpv 构建接受，只能在有音频输出的目标上试听；本机只到单元测试与编译层。
