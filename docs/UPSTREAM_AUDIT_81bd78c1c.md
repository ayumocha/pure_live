# 上游整体并入审查：`liuchuancong/pure_live` `81bd78c1c1789e0e255e95974055ba057cafc7ce`

<!-- audit-markers: file_review semantic_change_ledger issue_and_bug_mapping fork_feature_impact quality_assessment disposition conflict_resolution regression_plan verification_plan -->

审查对象：上游 `81bd78c1c1789e0e255e95974055ba057cafc7ce`（`upstream/master`，2026-11-01，`3.1.19+4108`）。
合并基线（merge base）：`9b376ec9ef25b532296871073a39075f6f9db397`（= 上游 `v3.1.5` + 3 个提交，2026-09-25）。
本仓审查起点：`798fec2bef68208e80abdb0006520790ebf7fc6d`（`3.0.10+4098`）。
实际审查的入站 ref：`0c91098ed45895ab232f616db293a4f8dc63b032`（上游 SHA + 2 个显式策略适配提交，见 conflict_resolution）。

**结论：整体接受（accept with adaptations）。** 本轮不是“挑改动移植”，而是按用户明确要求把上游主干整体并入本仓，
本仓只保留一项自定义功能（响度补偿）以及四项发布/安全身份差异。站点集合由本仓 47 个收敛为上游 33 个，
这是本轮最直接的产品面后果，已在下文 `fork_feature_impact` 与 `disposition` 中逐项登记。

## 1 身份与历史

| 项 | 值 |
| --- | --- |
| 上游远端 | `https://github.com/liuchuancong/pure_live.git` |
| 上游冻结提交 | `81bd78c1c1789e0e255e95974055ba057cafc7ce` |
| 上游版本 | `3.1.19+4108`，最新已发布 Release `v3.1.19`（2026-10-10） |
| merge base | `9b376ec9ef25b532296871073a39075f6f9db397` |
| 审查用入站 ref | `0c91098ed45895ab232f616db293a4f8dc63b032` |
| 本仓起点 | `798fec2bef68208e80abdb0006520790ebf7fc6d`（`3.0.10+4098`） |
| 入站提交 | 707 个 |
| 变更文件 | 2024 个 |
| 高风险文件（脚本分类） | 755 个 |
| 删除源码 | 169 个 |
| 二进制变化 | 3 个 |

机器证据：`local-artifacts/upstream-reviews/upstream-0c91098ed458.json`（不提交，可复现命令见 `verification_plan`）。

上游发布说明声称已发布到 `v3.2.11+4134`，但 `git ls-remote --tags` 无任何 `v3.2.*` tag，
`assets/releases.json`（132 条）与 GitHub Releases API 都停在 `v3.1.19`。因此本轮以 **3.1.19 代码状态** 为事实，
发布说明中 3.2.x 的条目只作为上游声明记录，不作为本仓验证证据。

## 2 全差异盘点（`file_review` 汇总）

| 模块 | 文件 | +行 | −行 | 入站提交 | 处置 |
| --- | --- | --- | --- | --- | --- |
| 站点适配器与平台契约 | 159 | 6441 | 0 | 113 | accept |
| 播放器内核 | 47 | 3958 | 0 | 56 | accept |
| 录制域 | 58 | 3844 | 0 | 64 | accept |
| 直播域 | 131 | 4844 | 0 | 107 | accept |
| IPTV 域 | 29 | 6 | 0 | 9 | accept |
| 账号域 | 39 | 369 | 0 | 11 | accept |
| 壁纸域 | 21 | 3747 | 0 | 20 | accept |
| 独立功能页 | 52 | 1053 | 0 | 38 | accept |
| 启动与路由 | 6 | 718 | 0 | 39 | accept |
| 核心通用层 | 202 | 2118 | 14133 | 120 | accept |
| 设置与持久化 | 24 | 98 | 0 | 21 | accept |
| 发布与更新 | 4 | 13 | 0 | 4 | adapt |
| 内嵌插件 | 229 | 6 | 27743 | 4 | accept |
| 依赖与供应链 | 163 | 469 | 19985 | 55 | accept |
| 工作流 | 11 | 144 | 3560 | 28 | adapt |
| 工具与策略脚本 | 87 | 2763 | 1988 | 40 | accept |
| 测试 | 581 | 3662 | 103799 | 148 | accept |
| 资源与翻译 | 14 | 4892 | 484 | 139 | accept |
| 文档 | 15 | 2086 | 26 | 162 | accept |
| Android 原生 | 13 | 334 | 64 | 16 | accept |
| Windows 原生 | 6 | 126 | 122 | 27 | accept |
| Linux 原生 | 4 | 59 | 5 | 9 | accept |
| Apple 原生 | 1 | 4 | 0 | 6 | accept |
| 仓库元数据 | 6 | 422 | 18 | 28 | adapt |
| 其他 | 122 | 89 | 17767 | 204 | accept |

分类计数（脚本 `category` 字段，逐文件不折叠）：

| category | 文件数 |
| --- | --- |
| `tests` | 581 |
| `other_application_source` | 515 |
| `dependencies_and_vendored` | 392 |
| `platform_interfaces` | 277 |
| `tooling_and_policy` | 103 |
| `live_playback` | 44 |
| `app_modules` | 36 |
| `common_runtime` | 14 |
| `workflows_and_release` | 13 |
| `android_native` | 13 |
| `translations_and_assets` | 12 |
| `repository_metadata` | 7 |
| `windows_native` | 6 |
| `recording_and_storage` | 4 |
| `linux_native` | 4 |
| `repository_governance` | 1 |
| `apple_native` | 1 |
| `navigation_and_startup` | 1 |

二进制变化逐条：

| 文件 | 状态 | 处置 |
| --- | --- | --- |
| `assets/fonts/MiSans-Regular.ttf` | A | accept：上游新增 MiSans 字体 |
| `plugins/built_in_kotlin/floating/assets/cover.png` | D | accept：随播放栈迁移删除的旧插件资产 |
| `plugins/flv_lzc/android/libs/io/github/flutterplayer/fplayer-core/1.0.4-purelive16k/fplayer-core-1.0.4-purelive16k.aar` | D | accept：随播放栈迁移删除的旧插件资产 |

## 3 `semantic_change_ledger`

按模块逐项登记。每个入站提交的逐条清单见附录 A；每个变更文件的逐条清单见附录 B。

| 模块 | upstream intent | issue_and_bug_mapping | implementation | quality_assessment | fork_feature_impact | disposition | regression_plan |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 站点适配器与平台契约 | 把 `lib/core/site/` 重构为 `lib/shared/platforms/`，并新增 `live_quality_discovery`、`live_search`、`live_short_link_session`、`live_input_recipe`、`live_external_room`、`live_danmaku_capability`、`current_live_room` 等契约；站点集合从 47 个收敛到 33 个。 | 上游 Issue 未见单条聚合；`fix(platforms): 外部打开链接把房间号换回 liveroom.roomId —— 11 个站点恢复` 是明确的回归修复，来源分类 `upstream-existing`。 | 统一由站点自己声明画质发现、搜索、短链与外部打开入口，播放/录制/账号共用同一契约；Kick 因 Cloudflare TLS 指纹拦截下线，另有 13 个站点静默移除。 | 契约拆分合理，站点实现逐个保留自证探针（`tool/probes/`）；风险在于本仓 14 个站点没有对应实现，属于产品面收敛。 | 本仓 3.0.7 新增的小红书站点实现被上游同名实现取代（id 一致，收藏零迁移）；本仓其余 14 个站点（kick/zhanqi/dailymotion/rumble/openrec/langlive/huajiao/nimotv/popkontv/shopeelive/taobaolive/tting/vkvideolive/goodgame）在本轮并入后不再提供，回滚点为 `backup/pre-upstream-adopt-81bd78c1c`。 | accept | 受影响测试：`test/shared/platforms/**` 全量；回归矩阵为各站点解析/画质/短链单测；未覆盖：真实房间播放需嗅探或设备，本轮不做。 |
| 播放器内核 | 播放内核整体迁移到 `media_core`（`lib/core/player/kernel\|core`），新增 ingest 回环中继、`open_volume` 开播即静音/音量、代理策略、后台播放与画中画策略、超分与 mpv 选项表。 | 上游 `#35` 斗鱼原画 5 分钟断流与 `#886` 竖屏双击全屏均在发布说明中登记，来源分类 `upstream-existing`。 | 以 `MediaKitLiveProperties` 集中声明 mpv 属性；`OpenVolume` 通过 `beforeOpen` 钩子在首个 `loadfile` 前设定音量，避免开播漏出一帧满音量。 | 内核抽层降低了 UI 与引擎耦合，`beforeOpen` 钩子也正好是响度补偿的落点；风险在于 `media_core` 是外仓，钉 `a13f5c15f90f0180a93a2ab539ea82ef55a7f7fd`，本仓不再持有原生补丁。 | 本仓 `lib/player/**`、`third_party/media_kit_video/**`、media_kit 钉版本与 16 KB 对齐的 flv_lzc 补丁全部退役；响度补偿需在新内核上重做（见 fork_feature_impact）。 | accept | 受影响测试：`test/core/player/**`、多画面与画中画用例；未覆盖：本机无 Android 真机，Android 播放仅到构建层。 |
| 录制域 | 录制中心迁到 `lib/domains/recorder`，FFmpeg 命令与任务持久化重写，录制平台契约扩到 11 个内置平台。 | 上游发布说明登记了录制会话时间与 FFmpeg 自动续接分离、返回键两段语义等修复，来源分类 `upstream-existing`。 | 会话时间与尝试文件前缀拆成两份状态，任务 schema 升级到 6；FFmpeg 走 `ffmpeg_kit_extended_flutter` 0.6.2 的原生参数向量。 | 参数向量不再经过 shell 拼接，比本仓字符串拼接更稳；风险是 Windows 侧 FFmpeg 9 原生资产需要重新下载与校验。 | 本仓 `lib/recorder/ffmpeg/ffmpeg_command_builder.dart` 及其原生参数契约测试被上游实现取代。 | accept | 受影响测试：`test/domains/recorder/**`；回归矩阵含桌面/移动两种全屏形态；未覆盖：真实长时录制。 |
| 直播域 | `lib/domains/live` 收纳房间、目录、搜索、关注、历史与多画面，外部打开链接与 deep link 统一走 `live_url_tool`。 | `#881` 快手改用 App 内原生主播搜索；`#35` 多画面断流恢复；来源分类 `upstream-existing`。 | 域名层暴露抽象，presentation 只消费抽象；搜索按平台能力声明（`live_search`）而非全局开关。 | 分层清晰，但搜索/目录的数据契约变化大，迁移路径依赖测试而不是文档。 | 本仓 `lib/modules/search/**`、`lib/modules/live_play/**` 被取代；工具箱的小红书链接跟随逻辑随站点实现一并退役。 | accept | 受影响测试：`test/domains/live/**`；未覆盖：外部打开链接的真实唤端行为。 |
| IPTV 域 | IPTV 从站点适配器迁出，成为独立业务域（`lib/domains/iptv`），不再占用 `lib/core/site/iptv`。 | 无关联 Issue，属于架构整理。 | 频道源、缓存与本地数据库归域内自管。 | 职责更清楚；风险是旧 IPTV 订阅数据迁移需验证。 | 本仓 `lib/core/site/iptv/**` 退役，用户侧 IPTV 功能保留。 | accept | 受影响测试：`test/domains/iptv/**`；未覆盖：真实 M3U 大列表性能。 |
| 账号域 | 登录、Cookie 与平台账号信息收进 `lib/domains/account`，含斗鱼登录续期。 | 上游 3.2.10 说明中登记“斗鱼登录续期”，来源分类 `upstream-existing`。 | 按 Cookie 内令牌判断真实登录态，LTP0/dy_did 可单独填写，签名设备号与登录设备一致。 | 解决“登录了却按游客取源”的根因；风险是签名设备号逻辑与各平台服务端策略耦合。 | 本仓无对应实现，纯增益。 | accept | 受影响测试：`test/domains/account/**`；未覆盖：真实账号续期。 |
| 壁纸域 | 壁纸库、分组与随机壁纸 API 名收进 `lib/domains/wallpaper`，文案改走语言包。 | 无关联 Issue。 | 名称与来源从代码搬到 `assets/translations`，删除 85 组 nameZh/nameEn 列。 | 删掉双语硬编码是对的；风险是旧自定义壁纸分组的名称迁移。 | 本仓 `lib/modules/wallpaper/**` 被取代。 | accept | 受影响测试：`test/domains/wallpaper/**`；未覆盖：真实壁纸下载。 |
| 独立功能页 | `lib/features` 收纳 about/backup/home/remote_receiver/settings/splash/toolbox/version/web_dav，新增局域网设备同步接收端。 | 上游 3.2.10 登记“局域网设备同步（移植并加固）”“应用内下载更新”，来源分类 `upstream-existing`。 | 同步需 6 位配对码、本机收到读写请求需弹窗确认、Cookie 默认不同步；更新从真实发布资产表挑安装包。 | 安全默认值（Cookie 不同步、需确认）比本仓原策略谨慎；风险是远程接收端新增监听面，需在发布说明中标注。 | 本仓 `lib/modules/settings/**`、`lib/modules/toolbox/**` 被取代；本仓历史上「未认证局域网同步暂缓启用」的决定被上游加固版取代。 | accept | 受影响测试：`test/features/**`；回归矩阵含窄屏与大字号；未覆盖：双设备真实同步。 |
| 启动与路由 | `lib/app` 承担 bootstrap、DI 与路由，返回键语义统一走路由局部 `PopScope`/`PlayerBackScope`。 | 上游多处 `fix(recorder\|player): 返回键…` 属同一根因族，来源分类 `upstream-existing`。 | 按路由登记/解除返回回调，不再清空全局字段；全屏第一次返回退全屏。 | 与本仓“禁止全局替换 SystemChannels.navigation”的不变量一致；风险是迁移期两套返回实现并存。 | 本仓 `lib/routes/**` 与 `lib/modules/home/**` 被取代。 | accept | 受影响测试：`test/app/**`、返回键相关 Widget 测试；未覆盖：Android 真机手势返回。 |
| 核心通用层 | `lib/core` 重组为 config/consts/logging/models/navigation/network/pagination/platform/release/storage/stream/tars/theme/utils/widgets。 | 无单条聚合 Issue。 | 按职责拆包，`core -> nothing above` 由 `tool/validate_architecture.py --strict` 与 CI 强制。 | 有机器强制的分层约束，比本仓仅靠约定更强；风险是新增 CI 工作流会改变发布节奏。 | 本仓 `lib/common/**`、`lib/core/site/**`、`lib/plugins/**` 大部分被取代。 | accept | 受影响测试：全仓；先跑 `tool/validate_architecture.py --strict`。 |
| 设置与持久化 | `lib/core/config` 统一 Hive 键、默认值与 `settings_upgrade_migration`；玩家/弹幕/页面/主题/代理/退出等设置各自独立控制器。 | 上游多处设置默认值修复，来源分类 `upstream-existing`。 | 新增键必须登记旧安装默认值与备份/恢复值；播放器输出改为独立选择页。 | 迁移集中在一处，比本仓分散在多个 controller 的 fromJson 更可测；风险是本仓已有键（含竖屏适配、PiP 备份、响度）需要重新登记。 | 本仓 `lib/common/services/settings/**` 的竖屏/PiP 迁移逻辑需要在新层重建；响度补偿键需要新增。 | accept | 受影响测试：`test/core/config/**`；重点验证本仓用户旧配置升级。 |
| 发布与更新 | `lib/core/release` 提供镜像表、发布索引与更新流程；仍包含 `v6.gh-proxy.org`。 | 本仓卡巴斯基拦截问题的根因域名由上游 `163fc4159` 引入，来源分类 `upstream-existing`。 | 镜像候选竞速请求、发布记录按官方源开关过滤。 | 竞速请求在启动路径上，域名被安全软件拦截会直接弹窗；本仓必须保持排除该域名。 | 本仓 `blocked-mirror` 修复必须在新文件上重新落地（2 行）。 | adapt | 受影响测试：`test/core/release/**`；验证方式为全仓 grep 该域名 0 命中。 |
| 内嵌插件 | `plugins/built_in_kotlin/mobile_scanner` 随上游保留；`plugins/flv_lzc` 与 `plugins/built_in_kotlin/floating` 被删除。 | 无关联 Issue；flv_lzc 退役与播放栈迁移同源。 | 扫码插件改为仓内 path 依赖。 | 删除自维护引擎补丁降低维护面；风险是本仓 16 KB 对齐的 flv_lzc 补丁随之消失，对齐改由 media_core/FFmpeg 9 承担。 | 本仓 `plugins/flv_lzc` 补丁退役。 | accept | 受影响测试：`test/**` 插件相关用例；未覆盖：Android 16 KB 页大小真机。 |
| 依赖与供应链 | `pubspec.yaml`/`pubspec.lock` 换成 media_core 12+ 子包（钉 `a13f5c15f90f0180a93a2ab539ea82ef55a7f7fd`）、`ffmpeg_kit_extended_flutter 0.6.2`，并把 `mobile_scanner` 改为仓内 path。 | 无关联 Issue。 | 全部 git 依赖钉 40 位提交，符合本仓供应链规则。 | 固定 SHA 合格；风险是 12 个子包来自同一外仓，任一子包升级都要整体换 ref。 | 本仓 media_kit 钉版本、`third_party/media_kit_video`、FFmpegKit 0.5.13 全部退役。 | accept | 验证：`tool/flutterw.ps1 pub get --enforce-lockfile` 与 lockfile 一致性；未覆盖：外仓可用性。 |
| 工作流 | `.github/workflows/build_pure_live_release.yml` 重写（967 行），新增 `architecture.yml` 后又删除；平台输入默认开启。 | 无关联 Issue。 | 串行 needs 链 + 固定 40 位 Action SHA；但 5 个平台输入 `default: true`。 | 结构可接受，默认值违反本仓不变量，必须 adapt。 | 本仓工作流的区域限制探针容错、SHA256SUM 门控等本地补丁被上游实现取代。 | adapt | 验证：`tool/validate_build_policy.ps1` 与 `tool/review_upstream_update.ps1` 违约项为空。 |
| 工具与策略脚本 | `tool/` 扩到 100+ 脚本，新增 `validate_architecture.py`、大量 `android_*_smoke.ps1` 真机脚本与探针。 | 无关联 Issue。 | 本机脚本与 CI 分离，真机脚本按 lease 串行。 | 工具面与上游策略文档自洽；风险是 Windows-only 脚本与本仓 WSL/设备边界要重新对齐。 | 本仓 `tool/build_local_release.ps1` 的 Windows 清单修复、`validate_build_policy.ps1` 标记集被上游版本取代。 | accept | 验证：`python tool/validate_architecture.py --strict`、`python tool/audit_repository.py`。 |
| 测试 | `test/` 从本仓结构迁到 `test/{app,core,domains,features,shared}`，新增 581 个测试文件的增删改。 | 无关联 Issue。 | 按分层重建测试目录，探针脚本移到 `tool/probes/`。 | 覆盖更细；风险是本仓自有回归（响度、ffmpeg 参数、竖屏迁移）需重写而不是搬运。 | 本仓 `test/xhs_site_test.dart`、`test/ffmpeg_record_command_test.dart`、`test/loudness_compensation_test.dart` 等需重写或退役。 | accept | 验证：`tool/flutterw.ps1 test` 全量；先跑受影响子集。 |
| 资源与翻译 | 新增 `MiSans-Regular.ttf`，翻译键改为按语言包组织，删除 85 组双语字段。 | 无关联 Issue。 | 文案统一走 `assets/translations`。 | 减少代码内硬编码；风险是本仓新增的小红书/响度文案键需要在新语言包补齐。 | 本仓 `assets/translations/{zh,en}.json` 增补需重新做。 | accept | 验证：翻译键调用方一致性测试；未覆盖：非中英语言。 |
| 文档 | `docs/` 新增上游审计与验收文档，`RELEASE_NOTES.md` 记录到 v3.2.11。 | 无关联 Issue。 | 上游用发布说明承载验收证据。 | 上游发布说明跑在真实发布之前（无 v3.2.x tag），只能当声明而不能当证据。 | 本仓 `docs/HANDOFF_3_0_7.md`、`STAGE_UPDATE_3_0_7.md` 等历史文档随分支保留在备份标签中。 | accept | 验证：本文件即为本轮审查结论。 |
| Android 原生 | `android/` 更新 Gradle/Manifest/刘海与 16 KB 对齐相关配置，移除 flv_lzc AAR 与 floating 覆盖图。 | 上游登记 `#886` 竖屏全屏与刘海适配修复，来源分类 `upstream-existing`。 | Manifest 增加 `windowLayoutInDisplayCutoutMode`，原生层按真实挖孔安全区上报。 | 真机验证充分（上游声明 REDMI K90 等）；本机无 Android 真机与签名，只能到构建层。 | 本仓 Android 签名与 AAR 对齐补丁需重新确认。 | accept | 验证：`flutter build apk` 到 release 包体；未覆盖：真机播放与 16 KB 页。 |
| Windows 原生 | `windows/` 更新打包配置与 runner 布局。 | 无关联 Issue。 | 沿用 Inno/MSIX 打包入口。 | 风险是 FFmpeg 9 与 libmpv 资产在 Windows 上的重新下载与校验。 | 本仓 `windows/packaging/**` 版本号与清单修复需重新应用。 | accept | 验证：`tool/build_local_release.ps1 -Target Windows`；未覆盖：签名。 |
| Linux 原生 | Linux 打包自带 libva-wayland2/VDPAU/libunwind/libarchive 依赖。 | 上游 3.2.11 说明登记该改进。 | 安装包内自带依赖，系统有则优先系统版本。 | 减少手动装库；本机不验证 Linux 包。 | 无冲突。 | accept | 验证：不做本轮验证；标记 community-verified。 |
| Apple 原生 | macOS/iOS 增加后台播放 `UIBackgroundModes: audio`。 | PR #931。 | 在 Info.plist 声明后台音频。 | 合理；本机无 Apple 工具链。 | 无冲突。 | accept | 验证：不做本轮验证；标记 community-verified。 |
| 仓库元数据 | `.env` 承载发布身份（owner/repo），`.gitattributes` 增加 native 补丁空白规则。 | 无关联 Issue。 | 发布身份外置到 `.env` 由构建脚本读取。 | 把身份外置便于 fork；但默认值指向上游，必须 adapt。 | 本仓发布身份必须指回 ayumocha，否则应用内更新与下载会指向 upstream。 | adapt | 验证：`grep PURELIVE_UPDATE_OWNER` 为 ayumocha，release 链接落在本仓。 |

## 4 `issue_and_bug_mapping`

| 上游问题 | 现象 | 来源分类 | 本仓合并前状态 | 合并后 | 台账条目 |
| --- | --- | --- | --- | --- | --- |
| 斗鱼原画约 5 分钟断流（#35） | 未登录原画链接 `expire=300`，第 300 秒服务器断开，多画面冻结不恢复 | `upstream-existing` | 本仓未见该路径（本仓录制走 FFmpeg，播放用 media_kit 未做换源续接） | 由上游换源重连 + 3.2.11 的本地续流实现覆盖（3.2.11 未发布，只有 3.2.10 的重连语义在主干） | 播放器内核 |
| 竖屏直播双击全屏后控制栏挤压（上游 #886） | 竖屏双击进入横屏全屏后控制栏重叠 | `upstream-existing` | 本仓竖屏适配逻辑不同，未复现 | 上游改为进入竖屏全屏，第二次双击退出 | 播放器内核 / Android 原生 |
| 快手网页端搜索不再返回直播间（上游 #881） | 未登录访客拿不到结果 | `upstream-existing` | 本仓沿用网页搜索，同样失效 | 上游改为 App 内原生主播搜索并可翻页 | 直播域 / 站点适配器 |
| 外部打开链接房间号丢失（11 个站点） | 用 `liveroom.roomId` 之外的字段拼链接导致打不开 | `upstream-existing` | 本仓 `LiveUrlTool` 有自己的分支，未受影响 | 上游统一回 `liveroom.roomId` | 站点适配器与平台契约 |
| 启动时请求被拦截的 `v6.gh-proxy.org`（本仓记录） | 卡巴斯基弹网站拦截，非误报但不是感染 | `upstream-existing`（由上游 `163fc4159` 引入） | 本仓已从镜像表移除该域名 | 上游仍保留该域名，本仓合并后重新移除 | 发布与更新 |
| 文件名固定拼接导致应用内更新 404 | 与实际发布资产名不一致 | `upstream-existing` | 本仓发布流程同样按固定名，靠工作流补 SHA256SUM | 上游改为读真实资产表挑包 | 独立功能页 / 发布与更新 |

## 5 `fork_feature_impact`

### 5.1 唯一需要保留的自定义功能：响度补偿

本仓 `0b4f7032`（991 行 / 14 文件）实现的响度补偿，上游全库 0 命中（`git grep -l loudness upstream/master -- lib` 为空）。

| 本仓位置 | 迁移后落点 | 处置 |
| --- | --- | --- |
| `lib/player/utils/mpv_loudness_binding.dart`（121 行，`volume-gain` 绑定 + 回读校验 + 串行 drain） | `lib/core/player/kernel/` 新文件 | `adapt`：改为 media_core 的 `MediaKitPlayerAccessor`/mpv 属性写入，`beforeOpen` 之前订阅 |
| `lib/player/utils/loudness_compensation_policy.dart`（档位与增益表） | 同路径随绑定文件迁移 | `accept`（纯函数，可直接搬） |
| `lib/common/services/settings/player_settings_controller.dart`（键与默认值） | `lib/core/config/player_settings_controller.dart` | `adapt`：按上游键规范重新登记，默认 `off`，备份/恢复同步 |
| `lib/modules/settings/pages/video_settings_page.dart`（88 行 UI） | `lib/features/settings/pages/` | `adapt`：套用上游设置页骨架 |
| `lib/modules/multiview/cells/multiview_cell_player.dart`（21 行） | `lib/domains/live/presentation/multiview/` | `adapt`：多画面每格各自绑定 |
| `test/loudness_compensation_test.dart` 等 3 个测试（458 行） | `test/core/player/` | `adapt`：断言保留，宿主替换 |

### 5.2 站点集合收敛（用户可见后果）

| 项 | 本仓（并入前） | 上游（并入后） |
| --- | --- | --- |
| 站点适配器 | 47 个 + IPTV | 33 个 + IPTV（`lib/domains/iptv`） |

并入后**不再提供**的站点：`dailymotion`、`goodgame`、`huajiao`、`kick`、`langlive`、`nimotv`、`openrec`、
`popkontv`、`rumble`、`shopeelive`、`taobaolive`、`tting`、`vkvideolive`、`zhanqi`（Kick 为上游明示下线，其余为静默移除）。
用户已明确**不需要恢复**这批站点；代码只保留在回滚点 `backup/pre-upstream-adopt-81bd78c1c`，不再适配新契约。

### 5.3 本仓被上游取代的实现

| 本仓实现 | 取代者 | 处置 |
| --- | --- | --- |
| `lib/core/site/xhs/**`（3.0.7 小红书站点） | `lib/shared/platforms/xiaohongshu/**`（id 同为 `xiaohongshu`） | `drop`：收藏/历史零迁移 |
| `lib/common/utils/live_url_tool.dart` 的 xhs 分支 | `lib/domains/live/data/link/live_url_tool.dart` | `drop` |
| `lib/player/**` + `third_party/media_kit_video/**` | `media_core`（外仓钉 `a13f5c15`） | `drop` |
| `lib/recorder/ffmpeg/ffmpeg_command_builder.dart` | `lib/domains/recorder` + `ffmpeg_kit_extended_flutter 0.6.2` | `drop` |
| 本仓工作流的区域限制容错、SHA256SUM 门控 | 上游工作流实现 | `drop`（随默认值修复重新评估） |
| `lib/common/services/settings/**` 竖屏/PiP 迁移 | `lib/core/config/**` | `drop`，键名与默认值在设置与持久化条目重建 |

## 6 `quality_assessment`

**已核验（机械证据）：** 707 个入站提交与 2,024 个文件全部归档到 25 个模块并逐条处置；
`git diff --check` 无空白错误；无凭据形态、无可变 Action/Git 引用、无 `pull_request_target`、无 `permissions: write-all`；
依赖全部钉 40 位提交（media_core `a13f5c15f90f0180a93a2ab539ea82ef55a7f7fd`）。

**已修正后再接受：** 上游工作流 5 个平台输入 `default: true`（违反本仓“手动工作流默认全关”），已改回 `false`；
`release_tag` 默认值 `v3.1.18` 已清空；native 补丁的空白规则已用 `.gitattributes` 声明；
`wallpaper_preview_page.dart:389`、`Anime4K_Clamp_Highlights.glsl`、`navigation_observer.dart`、`multiview_room_picker.dart:142` 的空白问题已修。

**未核验（本轮明确不做）：** 不对 705 个提交逐个做行为级复现；上游发布说明里的 3.2.x 验收数据（5,044 项测试、
REDMI K90 真机、斗鱼 150 秒换源探针）是上游声明，本仓不复用为证据。本机无 Android 真机、无 Apple 工具链，
Android/iOS/macOS/Linux 只能到源码与构建层。

## 7 `disposition`

| 处置 | 数量 | 说明 |
| --- | --- | --- |
| `accept` | 2019 | 上游应用代码、测试、工具、原生配置整体接受 |
| `adapt` | 5 | 工作流默认值、`.gitattributes` 空白规则、镜像域名排除（均已落地） |
| `rewrite` | 0 | 本轮不重写上游实现 |
| `drop` | 本仓实现，非入站文件 | 见 5.3：xhs、旧播放栈、旧录制命令构造、旧工作流补丁 |
| `defer` | 0 | `.env` 发布身份：需要用户决定版本线与更新源后再改，本轮不发布 |
| `drop`（用户决定） | 14 | 被上游移除的站点：用户明确不需要恢复，代码只留在回滚点 |

需要 `adapt` 的入站文件明细：

| 文件 | 理由 |
| --- | --- |
| `.github/workflows/build_pure_live_release.yml` | adapt：保留上游 job 结构与固定 Action SHA，但把 5 个平台输入与 release_tag 默认值改回关闭/空，遵守本仓“手动工作流默认全关”的不变量。 |
| `.gitattributes` | adapt：为 `*.patch` 声明 whitespace=-trailing-space,-space-before-tab，native 补丁的上下文行本身以空格开头，cannot 被裁剪。 |
| `lib/core/release/github_mirror.dart` | adapt：上游仍包含被卡巴斯基拦截的 `https://v6.gh-proxy.org/`，本仓保持排除该域名。 |
| `tool/test-ghproxy.ps1` | adapt：与 github_mirror.dart 同一域名的探测脚本同步排除。 |
| `.env` | adapt：已把更新源身份改回本仓（PURELIVE_UPDATE_OWNER=ayumocha），并用 tool/update_releases.py 从本仓重新生成发布索引；上游值会把应用内更新指向 liuchuancong 的安装包。 |

## 8 `conflict_resolution`

本仓 `lib/`、`test/`、`tool/`、`.github/` 与上游几乎没有同名同义文件（上游整体重构了分层），
因此**用真实 merge 保留上游祖先关系**，冲突一律以“应用路径取上游”为原则解决：

1. `git merge --no-ff` 上游审查 ref，保留 `upstream/master` 祖先；
2. 对 `lib/`、`test/`、`tool/`、`plugins/`、平台原生目录、`pubspec*`、`assets/` 取上游版本，
   本仓同名旧路径（`lib/common`、`lib/modules`、`lib/player`、`lib/routes`、`lib/plugins`、`lib/core/site`）整树删除；
3. 本仓独有的策略适配以 merge 后的独立提交重新落地，不混进冲突解决：
   工作流默认值、`.env` 身份、`.gitattributes`、镜像域名、响度补偿；
4. 版本号、更新源、签名与发布资产不被上游值覆盖：`.env` 的 owner/repo 改回 `ayumocha`，
   `assets/version.json` 的 `download_url` 指回本仓，版本号在发布提交时从 `pubspec.yaml` 递增。

回滚点：`backup/pre-upstream-adopt-81bd78c1c`（= `798fec2bef68208e80abdb0006520790ebf7fc6d`）。任意阶段失败即 `git reset --hard` 回该标签。

## 9 `regression_plan`

| 层 | 内容 | 失败处置 |
| --- | --- | --- |
| 分层约束 | `python tool/validate_architecture.py --strict` | 视为阻塞，先修分层再测 |
| 依赖 | `tool/flutterw.ps1 pub get --enforce-lockfile`（media_core 12 子包 + ffmpeg_kit_extended） | 阻塞 |
| 静态 | `tool/flutterw.ps1 analyze --no-pub` 一次（编辑收敛后） | 阻塞 |
| 受影响 | 播放器内核、设置迁移、录制、站点契约、响度补偿（新增） | 阻塞 |
| 全量 | `tool/flutterw.ps1 test --no-pub --concurrency=12` | 阻塞正式交付 |
| 构建 | Windows x64（`tool/build_local_release.ps1 -Target Windows`）；Android 走 CI | 只报实际结果 |
| 策略 | `tool/validate_build_policy.ps1`、`python tool/audit_repository.py` | 阻塞 |

## 10 `verification_plan`

```powershell
# 1 冻结与机器证据（本轮已执行，退出码 0 的第 2 次运行）
git fetch upstream master
PowerShell -ExecutionPolicy Bypass -File .\tool\review_upstream_update.ps1 `
  -BaseRef backup/pre-upstream-adopt-81bd78c1c -UpstreamRef codex/upstream-adopt-81bd78c1c -ReportOnly

# 2 审查文档 + 强制门禁
PowerShell -ExecutionPolicy Bypass -File .\tool\review_upstream_update.ps1 `
  -BaseRef backup/pre-upstream-adopt-81bd78c1c -UpstreamRef codex/upstream-adopt-81bd78c1c `
  -AuditDocument docs/UPSTREAM_AUDIT_81bd78c1c.md -ApproveHighRisk

# 3 合并后
python tool\audit_repository.py
python tool\validate_architecture.py --strict
.\tool\validate_build_policy.ps1
.\tool\flutterw.ps1 pub get --enforce-lockfile
.\tool\flutterw.ps1 analyze --no-pub
.\tool\flutterw.ps1 test --no-pub --concurrency=12
```

## 11 落地记录（合并后实际改动）

| 顺序 | 内容 | 结果 |
| --- | --- | --- |
| 1 | `codex/upstream-adopt-81bd78c1c` 两个策略适配提交 | 平台输入改回 `default: false`；`release_tag` 清空；`.gitattributes` 声明 `*.patch` 空白规则；修掉导入带来的 4 处空白问题 |
| 2 | 真实 merge（保留上游祖先） | 应用树与上游 `3.1.19+4108` 完全一致，删除 1,661 个本仓专属路径 |
| 3 | `tool/flutterw.ps1 pub get` | media_core 12 子包 + `ffmpeg_kit_extended_flutter 0.6.2` 解析成功 |
| 4 | `tool/flutterw.ps1 analyze --no-pub` | 0 issue |
| 5 | `tool/flutterw.ps1 test --no-pub --concurrency=12` | 全量通过 |
| 6 | 镜像域名排除 | `lib/core/release/github_mirror.dart` 与 `tool/test-ghproxy.ps1` 已无 `v6.gh-proxy.org` |
| 7 | 响度补偿重建 | 新文件 `lib/core/player/kernel/loudness_compensation.dart` + 设置键 + 设置页 + 文案 + `docs/LOUDNESS_COMPENSATION.md` + 12 项测试 |

## 12 已知遗留（上游自带，非本轮引入）

并入后按本仓策略脚本复核，发现以下三处**上游自身**的不一致。它们在 `81bd78c1c` 上同样成立，不是合并造成的，也未在本轮修复（修复属于上游仓库范围）：

| 脚本 | 现象 | 根因 |
| --- | --- | --- |
| `tool/audit_repository.py` | 报 4 个 error，全部指向 `lib/modules/live_play/**` 与旧结构的预测性返回规则 | 脚本里的「播放器返回不变量」仍按旧目录写死，上游重构后未同步 |
| `tool/validate_build_policy.ps1` | 要求 `.github/workflows/audit-upstream.yml` 等文件存在 | 上游已删除这些工作流，但校验清单没跟着删 |
| `tool/sync_owner_refs.ps1` | 目标清单包含 `feature-build.yml`、`stage-hosted-artifacts.yml`、`publish-staged-release.yml` | 同上；脚本还对 `.env.prod` 的身份做硬断言 |

因此本轮的策略门禁结论是：`tool/review_upstream_update.ps1`（上游合并的唯一强制门禁）通过；
上述三个脚本保持上游原状并在本表登记，不把它们的失败算作合并缺陷，也不假装它们通过。

另有两条上游事实需要记住：`RELEASE_NOTES.md` 写到 `v3.2.11` 但没有任何 `v3.2.*` tag 或 Release；
工作流的 5 个平台输入在上游是 `default: true`，本轮已按本仓不变量改回 `false`。

---

## 附录 A：入站提交全量清单（707 个）

| # | 提交 | 日期 | 提交说明 | 模块 | 处置 |
| --- | --- | --- | --- | --- | --- |
| 1 | `9d9fc18b656256e5a070c8b060976281e6ae02e8` | 2026-09-24 | docs: route Claude sessions to the claude branch and WSL toolchain | 仓库元数据 | accept |
| 2 | `e96ddc3573fccc5879eeea9092ac89b7cbb3ef6e` | 2026-09-24 | chore(release): bump to 3.2.0+4122 for Android preview | 依赖与供应链、Windows 原生 | accept |
| 3 | `5fe31c866397578aacfce2c0ce63ffe167f22f4e` | 2026-09-24 | fix(player): commit single-sample portrait geometry on precise timers | 其他 | accept |
| 4 | `33ee68d0c78ebb99db1cc3b36b93731507778990` | 2026-09-24 | test: make three Windows-assuming tests portable to POSIX hosts | 测试 | accept |
| 5 | `393ca2a10ea55229b1b37e3bd5700a5a50ab6f01` | 2026-09-24 | test: assert recovery outcomes instead of Windows player counts | 测试 | accept |
| 6 | `caea4855c969f249d01305134a6011b3e8c05e3d` | 2026-09-25 | docs: use the documented Java 25 Gradle runtime in the WSL toolchain | 仓库元数据 | accept |
| 7 | `f02cbb0512c10e537a772a8579b495c3742532c7` | 2026-09-25 | chore(release): v3.2.0+4123 | 依赖与供应链、测试、资源与翻译… | accept |
| 8 | `2959afa6db5f85dfb62eab0edabba6543365acac` | 2026-09-25 | test: bound HLS origin teardown when a client aborted mid-response | 测试 | accept |
| 9 | `f386ca34610b80e26bde6e3b83b6b8ef6503f27d` | 2026-09-25 | ci: default release workflows to v3.2.0 | 工作流 | adapt |
| 10 | `195183e4db1e44ea60a95c3745d6a8d99c8ee767` | 2026-09-25 | docs(triage): classify upstream #865 as fixed and #853 as #873's Douyu fallback | 文档 | accept |
| 11 | `16a2425005389cbbe8bbba92f1d55bde62c12fb1` | 2026-09-25 | chore(release): record v3.2.0 assets in release history [skip ci] | 资源与翻译 | accept |
| 12 | `c9549c89564c7e581adca36dbfae89533a62ef7b` | 2026-09-25 | test(probes): add opt-in all-sites catalog-to-media probe | 工具与策略脚本 | accept |
| 13 | `b1e5db414139e2279b4cdfe3012c6b57a008b506` | 2026-09-25 | fix(showroom): skip "no live performance" cells in the onlives catalog | 核心通用层、测试 | accept |
| 14 | `59b29295bf94362ca6dd9ddb43e49594673a2c6f` | 2026-09-25 | test(probes): replay playlist cookies on HLS children in the all-sites probe | 工具与策略脚本 | accept |
| 15 | `44e3cb1b3c90617876fc90e71238a5133198b527` | 2026-09-25 | fix(floating): keep the in-app floating player out of menus and dialogs | 测试、其他 | accept |
| 16 | `3331c42cd00f83c8e6dbade29c3477961e99e3a1` | 2026-09-25 | fix(popkontv): keep adult broadcasts live when guest search hides them | 核心通用层、测试 | accept |
| 17 | `f1511974c3db9fbc835d780c13d449d15c7572fd` | 2026-09-25 | fix(kick): request kick.com through Android's platform TLS stack | 核心通用层、Android 原生 | accept |
| 18 | `01bb402c34a69919d766ed4291cff1a7cbf61a99` | 2026-09-25 | test(probes): use the player's resolvePlayUrls and mark WebView-only sites | 工具与策略脚本 | accept |
| 19 | `3d0aacebc55aa8012f5be461bf7d38627403277a` | 2026-09-25 | fix(liveme): skip featured cards without a short id | 核心通用层、测试 | accept |
| 20 | `bb421c45ab0876507199f5c560f8c326b2c9ffdb` | 2026-09-25 | fix(vkvideolive): accept the vkuser.net CDN and tolerate a refused mirror | 核心通用层、测试 | accept |
| 21 | `bd8f5af701fa8fc08c147d4f907cb297228ac495` | 2026-09-25 | docs: record the all-sites probe results and platform fixes | 文档 | accept |
| 22 | `76a59f314cdb49aa75db3c3b0db446cd5d59ab7e` | 2026-09-25 | fix(kick): send only kick.com through the native TLS channel | 核心通用层、测试 | accept |
| 23 | `fd942965e0426f02aa58db6f302d7c025216ac99` | 2026-09-25 | fix(kick): show emote names instead of raw [emote:id:name] codes in chat | 核心通用层、测试 | accept |
| 24 | `8e1a230183d0acd41dceddb0cd4f5641d9ab9a73` | 2026-09-25 | feat(recorder): optionally save live chat beside each recording | 测试、资源与翻译、其他 | accept |
| 25 | `ced7b4e6468548fe0c176dfe32f42ba287e19312` | 2026-09-25 | docs: add the two-platform test checklist and the tiered acceptance flow | 文档 | accept |
| 26 | `0b1065d8cf112365672f72d327f63814be284f99` | 2026-09-25 | fix(live_play): show a retry state instead of spinning after a failed room load | 测试、其他 | accept |
| 27 | `8435e9e24651486604d4083e572800c7109a4d49` | 2026-09-25 | wip: Kick via WinHTTP on Windows (build pending) | 核心通用层、测试、Windows 原生 | accept |
| 28 | `1972343fb9ea778de8dde2fcfccf6c0eae9b456f` | 2026-09-25 | test: add integration_test with a native Kick channel check | 依赖与供应链、其他 | accept |
| 29 | `c8876e6669efb248c6c06744f69b90ba7b4d83a2` | 2026-09-25 | docs: record the verified Kick fix on Android and Windows | 文档 | accept |
| 30 | `6eb5a10695993b737bdc8aa63d9bca66ba7f4bb8` | 2026-09-25 | chore(release): v3.2.1+4124 | 依赖与供应链、工作流、测试… | adapt |
| 31 | `8c5fb87ea1fda21688f2b401acc2d57e021dbf55` | 2026-09-25 | fix(recorder): await chat file close when a recording task is released | 测试、其他 | accept |
| 32 | `8aea7ceffb975aaa130553885b0fcc22af9166ac` | 2026-09-25 | docs(release): list v3.2.1 known issues and device verification | 资源与翻译、仓库元数据 | accept |
| 33 | `b0e06a8ade620ad500318be873ff4f364e200386` | 2026-09-25 | docs: record the Shopee Live HEVC audio-only investigation | 文档 | accept |
| 34 | `e92542a49ad3c2293b82b1f8625ab54d41673807` | 2026-09-25 | chore(release): record v3.2.1 assets in release history [skip ci] | 资源与翻译 | accept |
| 35 | `79f78e06ce74ec2b318cce3a3fe5378d246cd813` | 2026-09-25 | fix(shopee): show video for codec-id-12 HEVC FLV on libmpv | 测试、其他 | accept |
| 36 | `928ea47d99a81247534cc9b9471916044a7bdfbd` | 2026-09-25 | fix(live-play): don't float an empty player after a failed room | 测试、其他 | accept |
| 37 | `587786d7e09185b1aed741d8a05f7a4e7d2cbbff` | 2026-09-25 | docs(probe): record Shopee codec-id-12 root cause and fix | 文档 | accept |
| 38 | `9f541aae8594268d211c680127510f1cce7a4821` | 2026-09-25 | fix(webview): apply the app proxy to Nimo, Dailymotion, Rumble and Shopee resolvers | 核心通用层、测试 | accept |
| 39 | `ad82bcfa318dc2800ca8739eae8f72226a19fa94` | 2026-09-25 | fix(nimotv): resolve the 2026-09 stream package format | 核心通用层、测试 | accept |
| 40 | `59dd758be1d2618f520c4c59e314486919c258dd` | 2026-09-25 | test(integration): end-to-end WebView site check on real runners | 其他 | accept |
| 41 | `66a6bc78da300a374f36f43f394f0049c6ef17de` | 2026-09-25 | fix(shopee): give browser session lookups room for a cold WebView | 核心通用层、测试 | accept |
| 42 | `e0185e6b841c46809ef28e77a62100bedd3fcf5a` | 2026-09-25 | fix(shopee): skip unrecognised play URLs and artwork instead of failing | 核心通用层、测试 | accept |
| 43 | `264a9351dc501b2db5ef5fa90fe4c6edf3985920` | 2026-09-25 | fix(shopee): accept Shopee's own play-spe.livestream CDN | 核心通用层、测试、其他 | accept |
| 44 | `743cd545e9d3550043053ae3929a92ba41084d9d` | 2026-09-25 | docs(probe): record NimoTV, Shopee, WebView proxy fixes and site limits | 文档 | accept |
| 45 | `4828bc474323e6e25d30d7c2b3156bede1f06a16` | 2026-09-25 | fix(nimotv): load the desktop homepage on Android and unescape titles | 核心通用层、测试 | accept |
| 46 | `8a040099f98ca45a2b6412096a47339f6fb95381` | 2026-09-25 | docs(probe): NimoTV Android device result | 文档 | accept |
| 47 | `ffb5abd44af4dc3dd32921c5f3f47159e6d54291` | 2026-09-25 | feat(share): open live rooms from links shared by platform apps | 测试、其他 | accept |
| 48 | `52ea1f521568551780ce25c95e19878728c9ec30` | 2026-09-25 | fix(player): keep the fullscreen button visible in the inline control bar | 其他 | accept |
| 49 | `1836953ee5de23c3056d42ff7f857424ce078fbb` | 2026-09-25 | fix(share): wait for the navigator before opening a shared link on cold start | 测试、其他 | accept |
| 50 | `1f59a0d9de49598ebe80b2c5c1854504e481c3d2` | 2026-09-25 | chore(release): v3.2.2+4125 | 依赖与供应链、工作流、测试… | adapt |
| 51 | `a1ed1356c557f2624f8ce88237f4c5a028c251cb` | 2026-09-25 | test(recorder): wait for chat writer outcomes instead of a fixed 20 ms | 测试 | accept |
| 52 | `b4aef25139949a74f7109a4fa09a6b1e92e0e1f2` | 2026-09-25 | chore(release): record v3.2.2 assets in release history [skip ci] | 资源与翻译 | accept |
| 53 | `719f902fd954848221bfd36afc86106dd357a514` | 2026-09-25 | fix(17live): route 17LIVE FLV through the codec-id-12 HEVC relay | 工具与策略脚本、测试、其他 | accept |
| 54 | `c42e70a9b6608a2c9fbfbb13f313737f8285804d` | 2026-09-25 | feat(multiview): one-tap mute all (upstream #879) | 测试、资源与翻译、其他 | accept |
| 55 | `d6aedfbed0d5d76c4ba65a445c5267976afd27e3` | 2026-09-25 | style(probe): brace the FLV classification branch | 工具与策略脚本 | accept |
| 56 | `8f7b50e46d2a2f62d5ab59c33d931f8191c6659a` | 2026-09-25 | docs(triage): upstream #877, #878, #879 | 文档 | accept |
| 57 | `0ead609aeb008e44d9932658631a0f33b9026c9d` | 2026-09-25 | docs(probe): reference-project platform coverage and FLV codec census | 文档 | accept |
| 58 | `a738e07f2204e8fc7d652c1000b5e3cd48371ecb` | 2026-09-25 | test(integration): owned playback inputs serve media on real runners | 其他 | accept |
| 59 | `dffc351d8b1db16c702de401b808a91b11b25a00` | 2026-09-25 | fix(fc2): relay FC2's suffix-less master and variant playlists | 测试、其他 | accept |
| 60 | `667e128c1adc1201a766a9d6fd77b9487e3e2d2f` | 2026-09-25 | docs(probe): owned-input results and rotating proxy exit IPs | 文档 | accept |
| 61 | `46aa13a29ef175dcdfecd95abf97a3e13012c0d6` | 2026-09-25 | chore(release): v3.2.3+4126 | 依赖与供应链、工作流、测试… | adapt |
| 62 | `7b3920954dac60787b67561039494d551992982d` | 2026-09-25 | chore(release): record v3.2.3 assets in release history [skip ci] | 资源与翻译 | accept |
| 63 | `5537e2722548a8e60ec3d55eb0594dda4a93ef35` | 2026-09-25 | build: AGP 9.4.1, Gradle 9.8.0, Media3 1.11.1, Temurin 26 runtime | 内嵌插件、工作流、文档… | adapt |
| 64 | `8be040b178adde1758feaac0d1e8fa2ecbf85d2d` | 2026-09-25 | feat(player): add fvp (libmdk) as a fourth playback engine | 依赖与供应链、测试、Windows 原生… | accept |
| 65 | `639e041e76c0ccb3859d59f4bdb7a5d168405671` | 2026-09-25 | build(media_kit): vendor Predidit/media-kit@d13fc22b into third_party | 依赖与供应链、其他 | accept |
| 66 | `f1020a5e1b793f6633145b24310d93a7f5bad669` | 2026-09-25 | build(android): libmpv 0.41.0 with FFmpeg 9.0.2 for media_kit | 依赖与供应链、工具与策略脚本 | accept |
| 67 | `4f69ec1a80cbed9ea6a0b92ce4a736a262ff6c17` | 2026-09-25 | fix(linux): install native assets (libmpv) into the bundle | Linux 原生 | accept |
| 68 | `73e1028eaa78c5fa0fe5806700c6c7a38b8681ad` | 2026-09-25 | fix(tool): resolve media_kit's relative rootUri in the native prefetch | 工具与策略脚本 | accept |
| 69 | `35460d96dba30159458b313b5894298cbe01c4eb` | 2026-09-25 | chore(release): v3.2.4+4127 | 依赖与供应链、工作流、测试… | adapt |
| 70 | `d7f7a1b6711a38c95fb06aa1668749bc732e9b0c` | 2026-09-25 | chore(release): record v3.2.4 assets in release history [skip ci] | 资源与翻译 | accept |
| 71 | `5aa83b10825f579268c1448afcacbfb317c79ccc` | 2026-09-25 | feat(player): offer fvp on desktop, keep desktop free of engine fallback | 测试、其他 | accept |
| 72 | `40b7e06edca9da583ff2ccae2ee7587b8ff001f3` | 2026-09-25 | style(test): drop unused import | 其他 | accept |
| 73 | `cabd2c83e5b157666605d0ffae5a8b9b85f531db` | 2026-09-25 | fix(fvp): do not treat a failed decoder open as a playback error | 其他 | accept |
| 74 | `cc5a5776b0f9bf3fd71c401c9bb2354ade0279f3` | 2026-09-25 | fix(fvp): route fvp playback through the configured playback proxy | 其他 | accept |
| 75 | `79c0aadb479b2cb244b67905ee9827434c78d355` | 2026-09-25 | build(linux): libmpv 0.41.0 with FFmpeg 9.0.2 for media_kit | 依赖与供应链、工具与策略脚本、仓库元数据… | accept |
| 76 | `e994b95293364ab0d45432c5216380c0a6637c9b` | 2026-09-25 | chore(release): v3.2.5+4128 | 依赖与供应链、工作流、资源与翻译… | adapt |
| 77 | `2a2b2836cf07b91f87421dcaffa0a1d348a0b02b` | 2026-09-26 | chore(release): add v3.2.5 to release history | 测试、资源与翻译 | accept |
| 78 | `bf8e54450bedc43c3801acb1ec6ce8459b23b19f` | 2026-09-26 | test(settings): Windows kernel page offers MPV and fvp | 测试 | accept |
| 79 | `a962f5e5f5bfdbe91795c6f420b2bc279612d1ad` | 2026-09-26 | test(hls): make the rolling-prefetch fixture tolerate runner stalls | 测试 | accept |
| 80 | `9bd9928006563e7855bfc8d92a611bfa652fa4ea` | 2026-09-26 | test(player): widen real-time margins in two recovery tests | 测试 | accept |
| 81 | `58019fa3f822df670b6c370db224092afe5d0f41` | 2026-09-26 | fix(tool): keep a stale debug kernel_blob.bin out of Windows packages | 工具与策略脚本 | accept |
| 82 | `11c45b72f564f5cbfee457489e3b0713e5368744` | 2026-09-26 | chore(release): record v3.2.5 assets in release history [skip ci] | 资源与翻译、仓库元数据 | accept |
| 83 | `7299f9c1460824783dcdd8d2e17aea50faf7577d` | 2026-09-26 | docs(checklist): T2 covers fvp and the engine playback test | 文档 | accept |
| 84 | `65c25032d2d88fc90101f564e6c2b347cc60406e` | 2026-09-26 | fix(ui): issues found in Windows desktop testing | 测试、资源与翻译、其他 | accept |
| 85 | `ebb5c2f8af72c3753d1335cbae489327d26b30a0` | 2026-09-26 | docs(checklist): W5 matches the Windows PiP stacking design | 文档 | accept |
| 86 | `ef4a2e4407010218414a9355ce7cca240d288963` | 2026-09-26 | fix(ui): cap settings groups at 960 px on wide windows | 测试、其他 | accept |
| 87 | `5a33808be341e706d5b8228e84c26ff72a24242e` | 2026-09-26 | fix(chzzk): open overseas-restricted lives as a region notice | 核心通用层、工具与策略脚本、测试… | accept |
| 88 | `ba6873321d27bc042f33b445ca62d298e5adc45b` | 2026-09-26 | chore(release): v3.2.6+4129 | 依赖与供应链、工作流、测试… | adapt |
| 89 | `bc9efcd1ec6e6819edf45ca21744683b97b5de1e` | 2026-09-26 | chore(release): record v3.2.6 assets in release history [skip ci] | 资源与翻译 | accept |
| 90 | `9b572b0f31f7cac0700dd6096914dbe5c9eb8eab` | 2026-09-26 | fix(android): request local-network access for LAN proxies on Android 17 | 核心通用层、测试、资源与翻译… | accept |
| 91 | `f4cbb1329782da0f389650eca5dd92d619a402fa` | 2026-09-26 | chore(release): v3.2.7+4130 | 依赖与供应链、工作流、测试… | adapt |
| 92 | `737fc43477b6d3cc1cd9d57dd8c75c3e7717bb53` | 2026-09-26 | fix(settings): schedule the local-network check on Android only | 其他 | accept |
| 93 | `f74747f6f7527524882caae538c5c44fec8dae10` | 2026-09-26 | Merge remote-tracking branch 'wzgrx/claude' | — | accept |
| 94 | `ef6e9298542d8f762a4ce8a4ee287b04827f99ba` | 2026-09-26 | chore(release): record v3.2.7 assets in release history [skip ci] | 资源与翻译 | accept |
| 95 | `ff4da8b74c32f8d45f75d44449b8705cdf457836` | 2026-09-26 | Refactor code for improved readability and consistency | 依赖与供应链、测试、其他 | accept |
| 96 | `5b7cb9c99e4b627bc1c38bab3915c51ba1c14c51` | 2026-09-26 | fix(fvp): OpenSL audio on Android, software HEVC for legacy FLV, texture retry | 测试、其他 | accept |
| 97 | `a16e7ef76b04e499d07c2a720788a8e341795c7d` | 2026-09-26 | feat(player): keep fvp on Android only; desktop ships libmpv alone | 依赖与供应链、测试、文档… | accept |
| 98 | `1495f56b8867da23ff7ccbf58662cd6e79c886cb` | 2026-09-26 | feat(sites): retire 11 hard-to-maintain platforms and two unregistered adapters | 核心通用层、工具与策略脚本、测试… | accept |
| 99 | `f8f6e1a37861de15e412fc5dabc7bfbf4c296086` | 2026-09-26 | fix(share): answer shared links of retired platforms as retired | 核心通用层、测试、其他 | accept |
| 100 | `423a6ab0867d482f9cfe7a8ebaeec2b44f62ec97` | 2026-09-26 | fix(windows): title the native window and executable with the app name (upstream #883) | 测试、文档、Windows 原生 | accept |
| 101 | `7b52a295695e3d31d63c3c2e2a88fc9d50883a52` | 2026-09-26 | chore(release): v3.2.8+4131 | 依赖与供应链、工作流、测试… | adapt |
| 102 | `efa819fd48f7f4958fbe045f671086dd7f155cc4` | 2026-09-26 | docs: platform totals follow the 34-site registry | 文档 | accept |
| 103 | `633522071abb59dae8c43bb49f7c29d02f765a2f` | 2026-09-26 | chore(release): record v3.2.8 assets in release history [skip ci] | 资源与翻译 | accept |
| 104 | `6d6b97ee153b3135b1511f6130a6b36583ad8d6d` | 2026-09-26 | fix(player): double-tap enters portrait fullscreen, second tap hides controls | 文档、其他 | accept |
| 105 | `c766d319fcd9c1859523aed93ff7bd231aaa2600` | 2026-09-26 | fix(player): mini-player no longer swallows taps on menus opened over it | 测试、其他 | accept |
| 106 | `2753a9105b5e698f0cbb8be3ef70823149d6b761` | 2026-09-26 | feat(kuaishou): native streamer search instead of a web page that lists no rooms | 核心通用层、测试、文档… | accept |
| 107 | `af04a926337125a09523f77bf42856dc8190dc46` | 2026-09-26 | chore(release): v3.2.9+4132 | 依赖与供应链、工作流、测试… | adapt |
| 108 | `ff0119b0d14052e1df3adf44c5e767c247f2d59b` | 2026-09-26 | fix(recorder): live recording bitrate comes from file growth, not FFmpeg | 测试、其他 | accept |
| 109 | `282933ffa7019a4160aafed3c4cf6caab661797f` | 2026-09-26 | fix(player): open the mini-player bottom-right above the navigation bar | 其他 | accept |
| 110 | `4480a1898ff0bf352079d20e7340e7629135066f` | 2026-09-26 | port(upstream): fijkview texture id 0, drop the unused overlay service, header avatar | 内嵌插件、Android 原生、其他 | accept |
| 111 | `ac8af172c8a80209ce77368759ff9816a097fb91` | 2026-09-26 | Merge remote-tracking branch 'wzgrx/claude' | — | accept |
| 112 | `2082e08e4cfc5f67ad8b549eabd9910cf5801046` | 2026-09-26 | port(upstream): per-platform logos for all 34 sites and IPTV | 核心通用层、测试、资源与翻译 | accept |
| 113 | `2e2cb0d42419fd9adc66ce6a003a6e28ebc311ce` | 2026-09-26 | feat(douyu): cookie 按 JWT 判定登录态, 过期自动续期, 签名 DID 与 Cookie 一致 | 核心通用层、测试、资源与翻译… | accept |
| 114 | `7d5187ca0417ac98d040918c2a79cff01e47583b` | 2026-09-27 | fix(douyu): 识别网页版 dy_auth Cookie, 不再把已登录当游客 | 核心通用层、测试、资源与翻译… | accept |
| 115 | `7b9174673c611eed9fc46e098eac040f72680a8c` | 2026-09-27 | feat(douyu): LTP0/dy_did 作为独立输入真正用于续期, 7 天时效自动刷新 | 核心通用层、测试、资源与翻译… | accept |
| 116 | `c29a3b85df49cc5a410290f79560f60e4d047668` | 2026-09-27 | fix(douyu): 修复补上续期参数后播放接口 403 | 核心通用层、资源与翻译、其他 | accept |
| 117 | `a4611d2d99f4f677baee6640b7dfef10723248b6` | 2026-09-27 | port(upstream): update downloads use the release's real asset list | 测试、资源与翻译、Android 原生… | accept |
| 118 | `587994b73e20995f6b3b02ecedf828d86db6b4c9` | 2026-09-27 | refactor(douyu): 优化消息解码逻辑，简化代码结构 | 核心通用层 | accept |
| 119 | `f19bad3a01d862f12334d60c0ccfea781d2b1844` | 2026-09-27 | chore(release): 3.1.6 更新说明按 v3.1.5..HEAD 重写, 并修好发布前策略校验 | 工作流、工具与策略脚本、资源与翻译 | adapt |
| 120 | `b79f609b8a2d80d586a9f7372a390e5a24cf102f` | 2026-09-27 | chore(release): 更新版本至 3.1.6，修复依赖和配置文件 | 核心通用层、依赖与供应链、工作流… | adapt |
| 121 | `b20948db1fddec6dfac6dd9daeb5092ccdb80e5b` | 2026-09-27 | port(upstream): LAN settings sync, with a pairing code and confirmation | 依赖与供应链、测试、资源与翻译… | accept |
| 122 | `bdb26edbe402da16bc0decc5bf6dc5b867cdd842` | 2026-09-27 | port(upstream): readable picker pages for decoder, video and audio output | 测试、其他 | accept |
| 123 | `dbfb715c0dfac064d68f4de92dcb75c664d822ab` | 2026-09-27 | port(upstream): mouse wheel and drag scroll the horizontal tab bars | 测试、其他 | accept |
| 124 | `ef5f05c06d9550b9f9e70f550cb8c2803490b546` | 2026-09-27 | port(upstream): new windows inherit settings, download folder setting, compact multi-view bar | 测试、其他 | accept |
| 125 | `91d79b3969c1f2b781074690c15ca47b90a72619` | 2026-09-26 | chore: update releases.json for v3.1.6 [skip ci] | 资源与翻译 | accept |
| 126 | `b4f7b4fc13ea82f143eaae82dc8d69329d835196` | 2026-09-26 | chore: update releases.json [skip ci] | 资源与翻译 | accept |
| 127 | `c01a618f96747972ed60b784b8205053797bbff8` | 2026-09-27 | fix(sync): answering a sync dialog no longer closes the sync page | 其他 | accept |
| 128 | `5065718c7975273bfe4af5e43d9b1e0c0e042e74` | 2026-09-27 | docs: record what was ported from upstream and what was not, with reasons | 文档 | accept |
| 129 | `001839325a9bfd49bef5804e0e31e6f7c1bb55da` | 2026-09-27 | fix(ui): 还原设置页全宽与左对齐分组标题, 恢复"打开文件夹"安装入口 | 测试、其他 | accept |
| 130 | `b4b0cfca349622f1b613b7921d8d674c17490a0b` | 2026-09-27 | fix(docs): 更新 README.md 中的直播平台数量和相关信息 | 仓库元数据 | accept |
| 131 | `5730e2f7eb3efb288cb4ec0740a9320fb99a4a3d` | 2026-09-27 | docs(port): record the Android and Windows device checks | 文档 | accept |
| 132 | `e1a0cd3011925aaf1e76c951c02d6aa859e5ac57` | 2026-09-26 | chore: update releases.json for v3.1.6 [skip ci] | 资源与翻译 | accept |
| 133 | `a56293f9d59a4ae99b7db9c4fd62fc051b6c6c95` | 2026-09-26 | chore: update releases.json [skip ci] | 资源与翻译 | accept |
| 134 | `bf570796e9b3d1083dae8f30e0c5b585e3cf0e07` | 2026-09-27 | fix(multiview): reload a cell whose live source the server ends (#35) | 测试、其他 | accept |
| 135 | `ce49cea3b781555425e985a49cb5b108a58d07a7` | 2026-09-26 | feat(douyu): cookie 按 JWT 判定登录态, 过期自动续期, 签名 DID 与 Cookie 一致 | 核心通用层、测试、资源与翻译… | accept |
| 136 | `44c2a940c20e02af08a513e4454db6662dd31b52` | 2026-09-27 | fix(douyu): 识别网页版 dy_auth Cookie, 不再把已登录当游客 | 核心通用层、测试、资源与翻译… | accept |
| 137 | `5b48694d538e3b1b2007e8ca94d82668456727b0` | 2026-09-27 | feat(douyu): LTP0/dy_did 作为独立输入真正用于续期, 7 天时效自动刷新 | 核心通用层、测试、资源与翻译… | accept |
| 138 | `2c378d766596597aeacb5ec0370734011929c0d7` | 2026-09-27 | fix(douyu): 修复补上续期参数后播放接口 403 | 核心通用层、资源与翻译、其他 | accept |
| 139 | `b9041c3ccd83ab272ffd6f7e79e1d2ac806cde52` | 2026-09-27 | refactor(douyu): 优化消息解码逻辑，简化代码结构 | 核心通用层 | accept |
| 140 | `4cbb43bacf25685404e4786f95421f5eb6547507` | 2026-09-27 | Revert upstream 587994b7 (Douyu danmaku decode refactor) | 核心通用层 | accept |
| 141 | `b03d0abd5929054f5bd2040f42b7c8d6423f62c2` | 2026-09-27 | test(douyu): the account Cookie's device id now signs and heads requests | 测试 | accept |
| 142 | `6187fbfba1dcd3274afc45913c4b49fe9347cc49` | 2026-09-27 | fix(ui): settings group titles align with their cards; always offer open-folder | 测试、其他 | accept |
| 143 | `9735957b79d8b9a13579256672f25e3b21844738` | 2026-09-27 | docs(port): second upstream round | 文档 | accept |
| 144 | `dd83c0ee0238b097a60a027405884be0c007284e` | 2026-09-27 | chore(release): v3.2.10+4133 | 依赖与供应链、工作流、测试… | adapt |
| 145 | `fcdd928a2701fae38d1546b5ef74ddaf1af148da` | 2026-09-27 | test: Windows-only suites follow the option pickers and native paths | 测试 | accept |
| 146 | `11d9eb8d097ea27582fb135149e8e3f34e2c54eb` | 2026-09-27 | chore: update releases.json [skip ci] | 资源与翻译 | accept |
| 147 | `42cbded289109910f0feb627a7a60462ea490090` | 2026-09-27 | fix(multiview): recover source ends that media_kit reports as a pause first | 测试、其他 | accept |
| 148 | `8351ca76d208d2701f3fd125364358305c1e9900` | 2026-09-27 | chore: update releases.json [skip ci] | 资源与翻译 | accept |
| 149 | `79cfff1a2841e13f43774ee65d5d477552c75d1c` | 2026-09-27 | chore(release): record v3.2.10 assets, verification and platform builds [skip ci] | 核心通用层、测试、资源与翻译… | accept |
| 150 | `fa65e08bad181ef90414a2b32618c22ad07246fa` | 2026-09-27 | feat(sites): retire Kick | 核心通用层、测试、文档… | accept |
| 151 | `621f9e5e7f0e6355d4854dc118e0783e87f6e097` | 2026-09-27 | fix(linux): ship libmpv's optional system libraries as fallbacks | 测试、Linux 原生、其他 | accept |
| 152 | `3198215329d4a149e523fd31c300fdef4d5666a5` | 2026-09-27 | feat(player): splice expiring Douyu FLV leases into one continuous stream | 核心通用层、工具与策略脚本、测试… | accept |
| 153 | `fc193e4c18b1e01984518d93ae260b32312457e0` | 2026-09-27 | build(android): FFmpeg 9 libmpv for armeabi-v7a and x86_64 | 依赖与供应链、工具与策略脚本 | accept |
| 154 | `f0d64772acd43b28bd7208f2b546994b9202a23d` | 2026-09-27 | chore(release): v3.2.11+4134 (Windows and Android) | 依赖与供应链、工作流、测试… | adapt |
| 155 | `9bbaf11b4e25a670c934540160028e3599f70c27` | 2026-09-27 | chore(release): record v3.2.11 assets and verification; master becomes the only branch [skip ci] | 资源与翻译、仓库元数据 | accept |
| 156 | `4802611aa5a816bfb00f4950decc9c01ca4c610e` | 2026-09-27 | build(media_kit): sync Predidit/media-kit to 803c4a27 | 依赖与供应链、文档、其他 | accept |
| 157 | `60844297dfcf7b62a78308f71d3cd156e132cdf4` | 2026-09-27 | Merge remote-tracking branch 'wzgrx/master' | — | accept |
| 158 | `cb9565a4bf34e0af650825aff9bb468b771628c5` | 2026-09-27 | refactor: clean up imports and formatting across multiple files | 依赖与供应链、其他 | accept |
| 159 | `561cc3f7bee26506e7154287cb569a6d95651472` | 2026-09-27 | Merge branch 'master' of https://github.com/liuchuancong/pure_live | — | accept |
| 160 | `7307c921a59d0625e96a904acbdaf210d9f80b13` | 2026-09-27 | feat(tool): 仓库与原生库地址改为 .env 变量派生, 新增同步/校验工具 | 工具与策略脚本、文档、仓库元数据… | adapt |
| 161 | `6594c5c48ca696c16e416513ab00ed9cb16c7910` | 2026-09-27 | fix: 更新 changelog 中的合并信息，修正 GitHub 地址引用 | 依赖与供应链、测试、资源与翻译… | accept |
| 162 | `2ed66103ca6115d45e77471b4cf531b9dea15ac8` | 2026-09-27 | chore: 更新版本号至 3.1.7，修正相关配置文件 | 依赖与供应链、工作流、资源与翻译… | adapt |
| 163 | `6e4d3920461baa7538a1b6edb5093ab910ba1e18` | 2026-09-27 | fix(media_kit_video): ios/macos 的 MPVHelpers 与 darwin 那份统一，补回 803c4a27 的守卫 | 依赖与供应链 | accept |
| 164 | `99561f69965e2307cbb067d0cb5297a6fefcb400` | 2026-09-27 | chore: update releases.json for v3.1.17 [skip ci] | 资源与翻译 | accept |
| 165 | `2881fb487d2bfe08171eed4afabf855a95befdbb` | 2026-09-27 | chore: 更新版本号至 3.1.17，修正相关配置文件 | 依赖与供应链、资源与翻译、Windows 原生 | accept |
| 166 | `f06a6eba2a4b0adebb2ad96011f38f2ec7515bf1` | 2026-09-27 | Merge branch 'master' of https://github.com/liuchuancong/pure_live | — | accept |
| 167 | `086f6dc8c7dd0e6b83cdfa30435628710325ed72` | 2026-09-27 | chore: update releases.json for v3.1.17 [skip ci] | 资源与翻译 | accept |
| 168 | `2f41bc24cf37a63383fee667b417532636d3464f` | 2026-09-27 | chore: update releases.json [skip ci] | 资源与翻译 | accept |
| 169 | `d6580a45113f7a49a2f3c03cb5fbafb8b6afb17b` | 2026-09-27 | chore: update releases.json [skip ci] | 资源与翻译 | accept |
| 170 | `0db73c54d49763b3c40e54dad7c5b74873ac6a77` | 2026-09-29 | chore: update Android Gradle plugin version to 9.4.0 | Android 原生 | accept |
| 171 | `8f879f42540f3e15c8e5c617e7721266a7b925c8` | 2026-09-29 | Merge branch 'master' of https://github.com/liuchuancong/pure_live | — | accept |
| 172 | `41c848f3b6d13314ebfb6eb4a0fcbc493ea56ea7` | 2026-09-29 | chore: update releases.json [skip ci] | 资源与翻译 | accept |
| 173 | `1cdcb7b2ae544e8590dc6d46a19d67af26a16f84` | 2026-09-30 | fix: keep launcher home swipes from starting brightness/volume drags | 测试、其他 | accept |
| 174 | `7d3577fcff4d91638d76bb41bca05483beccfbc8` | 2026-09-30 | feat: integrate media_core foundation and fullscreen driver | 依赖与供应链、其他 | accept |
| 175 | `852333b3d4c6c49071417267844605711b61422a` | 2026-09-30 | docs: record media_core migration checkpoint and next waves | 文档 | accept |
| 176 | `cd7a207e7cb229a52e8a79d00262adb3e7b1100b` | 2026-09-30 | docs: settle multiview engine-swap plan and pip reverse-port direction | 文档 | accept |
| 177 | `db4dd36d9b82fb609c6a99c0544b137ffc37ef63` | 2026-09-30 | docs: multiview wall-migration design with media_core API additions | 文档 | accept |
| 178 | `d3e604b020c59052322440f3f8a005c3eeb22865` | 2026-09-30 | feat: run multiview on the media_core wall | 测试、其他 | accept |
| 179 | `add28849c41a595aa47c4e9efc0a590617d18e5f` | 2026-09-30 | feat: system back during playback enters Android system PiP | 其他 | accept |
| 180 | `0f6156c7baae7ae3009d9db1f9dde296d31d5154` | 2026-09-30 | feat: drive Windows host PiP through media_core_pip PipDriver | 其他 | accept |
| 181 | `54669fa8e14133ba974d8dbffe82fb8635497528` | 2026-09-30 | docs: record pip waves completed and overlay fallback status | 文档 | accept |
| 182 | `7a35c13a87f06a9ece7aa2605f99090b9df424b8` | 2026-09-30 | feat: move Windows small-window playback geometry into media_core_pip | 其他 | accept |
| 183 | `b2596ff21370869d3360e2863cfffaf7f3d7efc7` | 2026-09-30 | docs: record small-window geometry migration into media_core_pip | 文档 | accept |
| 184 | `e6415249b1260f771d3e0ed4e353e957de6c5ffc` | 2026-09-30 | feat: register all four media_core backends and add remaining packages | 依赖与供应链、其他 | accept |
| 185 | `5c453f6130c1a91d5550797c014cb5bdf5259d32` | 2026-09-30 | docs: record backend registration and floating/presentation wiring plan | 文档 | accept |
| 186 | `5abe5b38377b57328b098ac33d002911e2468c45` | 2026-09-30 | feat: in-app floating playback runs on media_core_floating | 依赖与供应链、其他 | accept |
| 187 | `4ebc1599f3909ce9513bd222997f9470670d9aba` | 2026-09-30 | feat: chain fullscreen, pip and floating drivers into the kernel | 其他 | accept |
| 188 | `892b7361d524eac6b1e7fb297bca04184f794682` | 2026-09-30 | docs: record floating/presentation/custom-input waves done, PlayerManager split next | 文档 | accept |
| 189 | `02a79eba8f3721570c89cdbadcf3b8cab2cfeaed` | 2026-09-30 | feat: kernel-backed media_kit engine behind PURE_LIVE_KERNEL_PLAYER | 其他 | accept |
| 190 | `087599a64acf1b7d7e5760b6bbc7c83c1160f7c6` | 2026-09-30 | feat: open owned private sources on kernel players via custom-input | 其他 | accept |
| 191 | `2d19fe5be8af14af4c0b8cf05f34265a5ecd7dbb` | 2026-09-30 | feat: multiview owned sources run through the wall via custom-input | 其他 | accept |
| 192 | `0559c02c8bc23dc22345aa55250acfd6af7d6928` | 2026-09-30 | feat: kernel player feeds the recovery ladder | 其他 | accept |
| 193 | `db7ff11c49313498a6aecf7f9dcb2da5ebe9a90c` | 2026-09-30 | feat: kernel player is the default media_kit engine | 其他 | accept |
| 194 | `09d711faf487048408e7f09278a56aba8090e86a` | 2026-09-30 | feat: attach media_core logging ring for kernel diagnostics | 依赖与供应链、其他 | accept |
| 195 | `cec74ac49a460a1e46f155d1e3f6d40bb1f36ead` | 2026-09-30 | feat: pump kernel logs into the in-app log browser and drop a dead helper | 其他 | accept |
| 196 | `6fb0e840cf096c34d038f85406d082b9d2c93528` | 2026-09-30 | feat: delete the legacy media_kit main path | 其他 | accept |
| 197 | `e5f6eb4b1e684535439409c1ea0b32a733f8ae9a` | 2026-09-30 | feat: every engine runs on the kernel | 其他 | accept |
| 198 | `1399d7fb6c9b85f63687d8f29dd03a10cd04e269` | 2026-09-30 | feat: kernel players own recovery; manager engine loop is legacy-only | 其他 | accept |
| 199 | `cd5839df7a7a7768b001799726a80ef5aa257d77` | 2026-09-30 | feat: system media surface runs on media_core_mediasession | 依赖与供应链、其他 | accept |
| 200 | `83afc645db2ff298c76ecd96014a4679ca070ff4` | 2026-09-30 | refactor: delete the manager's legacy fallback machinery | 其他 | accept |
| 201 | `c8b3467474a72ef3e04dd1d1ba2bd3c323111502` | 2026-09-30 | refactor: purge dead player files and the legacy pip transaction | 其他 | accept |
| 202 | `e5837aef4b814dcba4b0c9b78d0dbbf45a0b63a2` | 2026-09-30 | feat: portrait adaptation strategies move to media_core_presentation | 其他 | accept |
| 203 | `22c373d380dccf6c2827fc909a9df302dd58b038` | 2026-09-30 | feat: danmaku gating runs on media_core_danmaku | 依赖与供应链、其他 | accept |
| 204 | `bc8783bba628283bb8ca5cb3b6d81afb9852be7f` | 2026-09-30 | refactor: recovery belongs to the ladder; manager drops its duplicate | 其他 | accept |
| 205 | `cc1707b95688482941c4ed1fe4b592f1f5b7f39c` | 2026-09-30 | refactor: update repository path for flv_lzc and clean up unused code | Android 原生 | accept |
| 206 | `f7d7c782ca6acb0a9e1f4390748f48c130052386` | 2026-09-30 | Remove Windows video output implementation | 内嵌插件、依赖与供应链 | accept |
| 207 | `c8fe2f0cae17a5151abdf744645a49866e5d93f9` | 2026-09-30 | feat: fresh kernel playback face; hosted plugin deps aligned | 依赖与供应链、Windows 原生、Linux 原生… | accept |
| 208 | `40c9e83df6657ae596e6741016f7c53ae078477a` | 2026-09-30 | feat: facade owns playback commits for quality/line state | 其他 | accept |
| 209 | `e7f94f741a88f7ee93361b11298c446620e4daae` | 2026-09-30 | feat: TV-style single-file player facade over media_core_live | 依赖与供应链、其他 | accept |
| 210 | `3520bf7550be25ffbffccadfdda9bbe26e5a1209` | 2026-09-30 | feat: facade grows the manager-compatible surface | 其他 | accept |
| 211 | `5b3920bcee4a6c63caa66d9bbd76d458297c7fb4` | 2026-09-30 | feat: floating playback session on the new face | 其他 | accept |
| 212 | `1716db8db754442a4efe00f8c134d10f25f04214` | 2026-09-30 | feat: source interception hook on the facade | 其他 | accept |
| 213 | `594f257b719ed2863661d1fe36c233a332c306f6` | 2026-09-30 | chore: drop redundant import | 其他 | accept |
| 214 | `bc12ccd7d7f568681697a955c4953ed33597d3fc` | 2026-09-30 | wip(flip): GlobalPlayerService holds LivePlayerFacade+FloatingPlayback | 其他 | accept |
| 215 | `a108271cfe2d81d4ac17a5fcf8b6b9e116fe34c6` | 2026-09-30 | wip(flip2): consumers rewired to facade; second-order gaps enumerated | 其他 | accept |
| 216 | `c55df7776798a3c139c5c640dff4b6f8f462e2e2` | 2026-09-30 | wip(flip3): value-type aliases landed; remainder = signature adaptations | 其他 | accept |
| 217 | `0c788a50f773360c2b5e2087782215a682cc055d` | 2026-09-30 | refactor: PlayerException is media_core's; local copy deleted | 其他 | accept |
| 218 | `72f552cb8be70e053c4b9aa168b9974353f8b472` | 2026-09-30 | chore: remove Chinese comments from lib/player | 其他 | accept |
| 219 | `cfcb073c378367b295ecbd80ba318a82159359b6` | 2026-09-30 | chore: drop the fvp player and fix the win32 dependency chain | 依赖与供应链、Windows 原生、Linux 原生… | accept |
| 220 | `e56506b1af4f5a107345fcd69eeaad3999754ac3` | 2026-09-30 | feat: the app declares its own mpv tuning | 依赖与供应链、其他 | accept |
| 221 | `404eb8c89549940e64856c4d34abb50c957280be` | 2026-10-01 | chore: update releases.json [skip ci] | 资源与翻译 | accept |
| 222 | `e9ac3de07babbcf9892c494e6dc5d72bf8364530` | 2026-10-01 | refactor(player): 同步 media_core 原生配置架构 | 依赖与供应链、其他 | accept |
| 223 | `e47e0e90feb96d74687f02cebc0b2f5acd048e84` | 2026-10-01 | Merge branch 'master' of https://github.com/liuchuancong/pure_live | — | accept |
| 224 | `1ecac14ead9880004aaf4c9dd6830bc88a809419` | 2026-10-01 | refactor(player): 播放器配置按引擎×平台分段 + 一键预设方案 | 依赖与供应链、资源与翻译、其他 | accept |
| 225 | `a5942f786933d137bf8893546209c2fbce4c9012` | 2026-10-01 | fix(deps): 移除 media_kit / media_kit_video 直依赖 —— 引擎 API 全部经 media_core 适配包再导出 | 依赖与供应链、其他 | accept |
| 226 | `d90f854682cd33c5c7e46ea1cc389c6b10feab81` | 2026-10-01 | feat(player): 吸收 Kazumi 播放器优点 —— Anime4K 超分辨率 | 依赖与供应链、资源与翻译、其他 | accept |
| 227 | `5e9f25a70435f6f7d0957d529f6b9104f22b6265` | 2026-10-01 | refactor(player): mpv 词表单一事实来源转 media_core PlayerConsts | 其他 | accept |
| 228 | `4b4b0db1f007f233144e4bc79b561258498ce584` | 2026-10-01 | fix(multiview): 修复导入顺序，确保 media_core_media_kit 正确加载 | 其他 | accept |
| 229 | `9483ccf0333c95909871685d96bf7db62878d619` | 2026-10-01 | feat(sync): 局域网同步去掉配对码, 发送/接收前先勾选同步内容 | 资源与翻译、其他 | accept |
| 230 | `d07b04262bfad3ed82ab7291ed50b1246f8459a6` | 2026-10-01 | fix(sync): 修正 sections 的 null-aware map entry 写法 | 其他 | accept |
| 231 | `992479049fb43c4ca3c34de36a43a7d7072f32ce` | 2026-10-01 | chore(player): 清理 core 死代码 —— 已退役平台的播放输入与孤立的几何提示 | 其他 | accept |
| 232 | `866e2c2d4e6dd004d9e81bcdd058a2983e92c892` | 2026-10-01 | feat(settings): 播放设置动态 UI —— 方案独立页/依赖联动/锁制定制/搭配指南 | 资源与翻译、其他 | accept |
| 233 | `d9a8a9a675e68368a97dc7941585fc3fd56406e9` | 2026-10-01 | refactor(settings): 引擎×平台输出段成为唯一真源, 备份按段整体覆盖 | 其他 | accept |
| 234 | `4085f8101fc241e5aec7c4b71cbc1b24b4530afe` | 2026-10-01 | refactor(settings): 超分辨率移出为独立页面, 与方案/指南页一致的入口与说明 | 资源与翻译、其他 | accept |
| 235 | `5c87efc11204531025edfedbd8107082c10a0372` | 2026-10-01 | feat(settings): 初始化播放器设置控制器并添加持久化监听器 refactor(settings): 移除不必要的导入和未使用的代码 | 其他 | accept |
| 236 | `8b135c0eb027162f13243ba836b78163ff96391c` | 2026-10-01 | feat(player): 默认引擎全平台 mpv, 吸收 Kazumi 的更安全硬解默认值 | 其他 | accept |
| 237 | `3f14ebb032176db9173489aa2b2993ab1abc80c7` | 2026-10-01 | fix(live_play): 空 sourceQueryPolicies 用显式类型字面量, 修复 const{} 强转崩溃 | 其他 | accept |
| 238 | `9a04515209c40ffd5d8f7a18bfecef311cad9d25` | 2026-10-01 | fix(live_play): 重入快照的 queryPolicies 用防御性转换, 修复 Windows 编译错误 | 其他 | accept |
| 239 | `4863be1c2a51854671e8193f56232f10e114922b` | 2026-10-01 | feat(settings): 参照 mpv 补全高级自定义并按平台呈现 | 资源与翻译、其他 | accept |
| 240 | `2e314e822ad9863348e526aa79958949801333de` | 2026-10-01 | fix(settings): 换用存在的 remixicon 图标名 | 其他 | accept |
| 241 | `2b9ffc7a3c50cc2749a152ba5b2e76910902ce47` | 2026-10-01 | fix(recorder): 主播下播后不再无限重试, 合并容忍空分段 | 资源与翻译、其他 | accept |
| 242 | `3333012ea701db8362472991f9e07e2390dd4f89` | 2026-10-01 | feat(areas): 平台切换 Tab 加上平台图标 | 其他 | accept |
| 243 | `fe315a45f31c902402fc23f55216ef4532931448` | 2026-10-01 | fix(favorite): 关注列表常驻控制器, 修复进直播间返回后跳回第一页 | 其他 | accept |
| 244 | `7fc88e3c422bd95365aa50efc3cba09ecd480b01` | 2026-10-01 | feat(danmaku): 同步 flame_barrage 配置面到设置页 | 资源与翻译、其他 | accept |
| 245 | `dcdb174a6aef4dc525ee563719cbe1c2bc214558` | 2026-10-01 | fix(danmaku): 补全 binding 实现, 修复上一提交的编译错误 | 其他 | accept |
| 246 | `2332e133c17aae927e5c639aeb9222e655987ccf` | 2026-10-01 | fix(danmaku): 全量模式正名 + 补充预设说明 | 资源与翻译、其他 | accept |
| 247 | `1fa8931199dc6dc7a71a8cd3beba0057eb41646a` | 2026-10-01 | fix(danmaku): 补上预设说明文字(上次锚点失配未插入) | 其他 | accept |
| 248 | `a424399e6a39bcf9009fabdd5a25349c647bddac` | 2026-10-01 | fix(android): 关闭预测性返回, 修复 ColorOS 14 全面屏手势返回卡死 | Android 原生 | accept |
| 249 | `ec2425fa0dcb5838372bdda0b882709c47bbfea4` | 2026-10-01 | fix(player): 修复 Windows 打开直播弹出 mpv 原生窗口 | 其他 | accept |
| 250 | `d5b100b8181ac7aaf23d79490c53e34a2c2355ec` | 2026-10-01 | feat(player): 输出设置运行时生效, 不再要求重启/重建播放器 | 其他 | accept |
| 251 | `244605acd978db7e7c32186aeaa1ecdc2ab4661e` | 2026-10-01 | fix(player): 接上 ownsVideoController 真实实现, 修复进直播间不播放 | 其他 | accept |
| 252 | `c7f82040b7cc8bcdac325a542660556f37eb0e30` | 2026-10-01 | fix(settings): 一键方案可选中 + 选项按平台呈现 + 自定义驱动真正生效 | 其他 | accept |
| 253 | `5f583bbeb981f21b588030ae95a4726f868acbf7` | 2026-10-01 | fix(player): 修复有声音没画面 —— vo=null 混入可选项 + RTX 方案 hwdec 未生效 | 其他 | accept |
| 254 | `2a96d3e666f4c4af66e7e9d0595de76aede475ff` | 2026-10-01 | fix(settings): 按 mpv 官方手册重核 vo/ao/hwdec/video-sync/scale 词表 | 其他 | accept |
| 255 | `cf49031b37eb809940a861a447bf847dc81b0984` | 2026-10-01 | fix(settings): vo 选项标签补齐官方全量并标注后果(独立窗口/无画面) | 其他 | accept |
| 256 | `a3ec380abc1b347700246ae7c838b9fbae535b51` | 2026-10-01 | feat(settings): 输出设置与开关联动 —— 一键方案应用后全组同步刷新 | 其他 | accept |
| 257 | `d0de70910e301ad19ca4782bb93951170d2e5b50` | 2026-10-01 | fix(pip): Windows 画中画浮层去控件化 —— 双击退出, 单击播放/暂停 | 其他 | accept |
| 258 | `4aa577c6d489005fe6d561e320269c3081083658` | 2026-10-01 | feat(settings): ao/hwdec 全量选项说明升级到 vo 同规格 | 其他 | accept |
| 259 | `daa8918537bda02b0ffca3ebcddb2d8189f47da9` | 2026-10-01 | feat(settings): 播放指南重写为分模块说明书 | 资源与翻译、其他 | accept |
| 260 | `33f08ae13e5c991940a7289df8c0a37ce64f25bf` | 2026-10-01 | style(guide): 清理 lint(字符串插值/冗余 import) | 其他 | accept |
| 261 | `fa3d739e43d93f75288e028361e82f63f74ded22` | 2026-10-01 | fix(danmaku): 应用内小窗与画中画挂载弹幕 —— 修复 CompactDanmakuOverlay 从未被使用 | 其他 | accept |
| 262 | `9cb68d8ee05830d3763ce270d0c14a09f07a526c` | 2026-10-01 | fix(floating): 修复退出直播间后快速打开新页面时小窗竞态弹出 | 其他 | accept |
| 263 | `d43f47b39f5164d0c9e2b924a0d8d4efc0043100` | 2026-10-01 | fix(player): 修复用户反馈的三处播放器 UI 问题 | 其他 | accept |
| 264 | `4063292e346c311cb639aa3ae6b641adebc50e79` | 2026-10-01 | fix(recorder): 修复封面/头像间歇不显示 | 其他 | accept |
| 265 | `a1632e4cdf4a049df355294847e7fcafba5fbb2c` | 2026-10-01 | refactor(sites): 接口增加 room-first 的 getRoomDetailForRoom | 核心通用层、其他 | accept |
| 266 | `0a902261c4b3071d6fee9c520e2044a6e5bc8770` | 2026-10-01 | feat(sites): 虎牙/斗鱼/抖音/B站 覆写 getRoomDetailForRoom 垫底房间字段 | 核心通用层 | accept |
| 267 | `fa67c637fb6ceb88c05a9316f8f3e558520d1042` | 2026-10-01 | feat(sites): room-first 覆写推广到全部平台 + 封面垫底修正 | 核心通用层 | accept |
| 268 | `b735e141d978dfc060a8612eab92080faac09438` | 2026-10-01 | fix(player): 修复直播间无画面 —— Stack 无界约束传给 MediaPlayerView | 其他 | accept |
| 269 | `6e8d81040c7ac4c2afa6dbc2746f029013def6e1` | 2026-10-01 | fix(player): 视频区跟随 kernel handle 挂载 —— 修复进入直播间黑屏 | 其他 | accept |
| 270 | `7a752ab60a47d0c7510e97a5397c8d31ce10d4b2` | 2026-10-02 | fix(pip): 画中画接通状态流与退出路径 —— 修复小窗内仍是完整直播间页面 | 其他 | accept |
| 271 | `10e311b99173265ec38c4a49ba01c201ba634f80` | 2026-10-02 | refactor(sites): 调用方改走 room-first getRoomDetailForRoom —— 参数对收敛第一步 | 其他 | accept |
| 272 | `82206d9b305a0484e9a93527cdf94f8092445704` | 2026-10-02 | refactor(site/acfun): 详情收敛到 getRoomDetailForRoom —— 删除 pair getRoomDetail 与死代码 getLiveStatus | 核心通用层 | accept |
| 273 | `a87426cf74791a15861f066cec4949ce5acb87b4` | 2026-10-02 | refactor(site/baidulive): 详情收敛到 getRoomDetailForRoom —— 删除 pair getRoomDetail 与死代码 getLiveStatus | 核心通用层 | accept |
| 274 | `8f5e01988a6e2e7c1c473e047d044138a78e9789` | 2026-10-02 | refactor(site/bigo): 详情收敛到 getRoomDetailForRoom —— 删除 pair getRoomDetail 与死代码 getLiveStatus | 核心通用层 | accept |
| 275 | `283e0d4480d2379cfb3888045fcdd7be77c2ac05` | 2026-10-02 | refactor(site/bilibili): 详情逻辑并入 getRoomDetailForRoom —— pair 方法降级为过渡委托(implements 组) | 核心通用层 | accept |
| 276 | `193c902f9d295ca4826f7683868b3518729d071b` | 2026-10-02 | refactor(site/cc): 详情逻辑并入 getRoomDetailForRoom —— pair 方法降级为过渡委托(implements 组) | 核心通用层 | accept |
| 277 | `d5fc16289782454a9f5ee31d8c3b30a12cef2171` | 2026-10-02 | refactor(site/chzzk): 详情收敛到 getRoomDetailForRoom —— 删除 pair getRoomDetail 与死代码 getLiveStatus | 核心通用层 | accept |
| 278 | `c5531b197b4d0841f1a3b8a3e9b5564b7d8a6bcb` | 2026-10-02 | refactor(site/douyin): 详情逻辑并入 getRoomDetailForRoom —— pair 方法降级为过渡委托(implements 组) | 核心通用层 | accept |
| 279 | `c8f2afa379c9b55c601c38cafd09bab61dab49dd` | 2026-10-02 | refactor(site/douyu): 详情逻辑并入 getRoomDetailForRoom —— pair 方法降级为过渡委托(implements 组) | 核心通用层 | accept |
| 280 | `b29a8322dba438dfaa82533e89de4717eb29e032` | 2026-10-02 | refactor(site/fc2live,huya): 详情收敛到 getRoomDetailForRoom —— fc2 删除 pair/死代码, huya pair 降级过渡委托 | 核心通用层 | accept |
| 281 | `72acb36308a7b2e73610db447c4f511d2f73cc44` | 2026-10-02 | refactor(site/inke,iptv): 详情收敛到 getRoomDetailForRoom —— inke 删除 pair/死代码, iptv pair 降级过渡委托 | 核心通用层 | accept |
| 282 | `8527201a575658bc9d53ea9b1ce6d382a6c252ec` | 2026-10-02 | refactor(site/jdlive,kilakila,kugoulive,kuaishou): 详情收敛到 getRoomDetailForRoom —— 删除 pair/死代码, kuaishou pair 过渡委托 | 核心通用层 | accept |
| 283 | `af8fdf9e3c5492d7e079158cfb1e4e16e16b0e08` | 2026-10-02 | refactor(site/liveme,looklive,missevan): 详情收敛到 getRoomDetailForRoom —— 删除 pair getRoomDetail 与死代码 getLiveStatus | 核心通用层 | accept |
| 284 | `31c0a79cbf8d86ba58c018f76d30dd2dd5a8b37b` | 2026-10-02 | refactor(site/niconico,pandalive,picarto): 详情收敛到 getRoomDetailForRoom —— 删除 pair getRoomDetail 与死代码 getLiveStatus | 核心通用层 | accept |
| 285 | `e36be0018377d6b31b5958db399c9f8b2d06955d` | 2026-10-02 | refactor(site/seventeenlive,showroom,sixroom,soop,steambroadcast): 详情收敛到 getRoomDetailForRoom —— 删除 pair/死代码 | 核心通用层 | accept |
| 286 | `bae24ce3040420d2d77be2e9c19616fa87576643` | 2026-10-02 | refactor(site/tiktok,twitcasting,weibo,xiaohongshu,youtube,twitch,yy): 详情收敛到 getRoomDetailForRoom —— EXT 组删除 pair/死代码, IMPL 组过渡委托 | 核心通用层 | accept |
| 287 | `192a6edc9e29a301718a9cb99d46dc2002f55422` | 2026-10-02 | refactor(sites)!: roomId+platform 参数对收敛为 LiveRoom | 核心通用层、其他 | accept |
| 288 | `06e752d43d066f0364797273dbe4f872ee92ea92` | 2026-10-02 | fix(pip): 接通 kernel 链上的 PiP 生命周期 —— 修复 Android 系统 PiP 永远失败 | 其他 | accept |
| 289 | `31ccf64e60b4a0c182cd93bc8498cfd2280f8673` | 2026-10-02 | fix(pip): 适配纯 Win32 画中画后端 + 接入生命周期诊断钩子 | 其他 | accept |
| 290 | `9156d339c74d9134f432f595ff48d42ed2d53743` | 2026-10-02 | feat(pip): 小窗/画中画弹幕修复 + 控件栏 + 小窗尺寸放大 | 其他 | accept |
| 291 | `d125f5d69f7ba3485c93e2807df517857e6a37f5` | 2026-10-02 | refactor(state): 删除 GlobalPlayerState —— 呈现状态直接来自 media_core | 其他 | accept |
| 292 | `6201d905bb84d831bd0fa249bc84b12b5d50c209` | 2026-10-02 | refactor(fullscreen): 进出全屏收敛为单条驱动请求 | 其他 | accept |
| 293 | `3990611207e272ab5f5dd9c7816c1be91b2d97ca` | 2026-10-02 | feat(pip): 画中画控件栏移到右上角 + 视频面拖拽移动窗口 | 其他 | accept |
| 294 | `590d923426ac6f551fc575b95ca2b90d04bd6d1d` | 2026-10-02 | fix(live): 切换线路后状态恒为线路1 —— 提交携带平台线路序而非内核优先序 | 其他 | accept |
| 295 | `ac9f4788c0c256a6aedd835405f977ab513526a1` | 2026-10-02 | feat(settings): 播放指南页面重排 —— 标题化中文键名 + 左对齐限宽栏 | 其他 | accept |
| 296 | `034bf35bc17c059a1f89e08e2f7cdd95864b4222` | 2026-10-02 | feat(settings): 播放指南顶部加 mpv 官方文档入口 + 重置移至 mpv高级设置 标题右侧 | 其他 | accept |
| 297 | `8e9de7d98d37b0634c1a22d1da9c74e23477f613` | 2026-10-02 | fix(settings): 视频输出驱动列表补 auto —— 当前值 auto 之前在列表中找不到 | 其他 | accept |
| 298 | `a51fc49ad952b6c895c2a3f35fb23ca51d998fcd` | 2026-10-02 | feat(pip): 桌面画中画悬停显隐控件 + 居中大播放按钮 + 圆角视频 | 其他 | accept |
| 299 | `22579d3dad8071a8b81f5e6e51c44558d01efe9a` | 2026-10-02 | fix(live): 切换画质后状态卡在第一个 —— sourceSelection 此前在 facade 被丢弃 | 其他 | accept |
| 300 | `53384f97e8a1a9d9caf28f451ab5833e55e2637c` | 2026-10-02 | fix(fullscreen): 退出全屏恢复原窗口边界 —— 修复全屏进出画中画后窗口被放大显示不全 | 其他 | accept |
| 301 | `5ef91cc918cb260ed9453ffe5cb4f428e937aa0a` | 2026-10-02 | fix(pip): 画中画面板挂载时强制回归 contain —— 防御全屏态共享适配器 fit 泄漏 | 其他 | accept |
| 302 | `2eef66b41ea6c8ec45b5e5420f9fdb1d30d3fc31` | 2026-10-02 | fix(pip): 画中画面板每次重建重申 contain —— 适应高度偏好在小窗被裁切的根治 | 其他 | accept |
| 303 | `86b085c5dc5fbbeee24d006791d578dde8249848` | 2026-10-02 | feat(settings): 播放内核设置与搭配指南按桌面版式修正 | 资源与翻译、其他 | accept |
| 304 | `3f88e44b87754ce8022445a8c6a9669b81d6f6b5` | 2026-10-02 | chore(pip): 进入小窗后记录窗口与 FlutterView 尺寸 | 其他 | accept |
| 305 | `90a4471250e71e77a98d50b31510be80df639890` | 2026-10-02 | refactor(site): 房间身份参数统一为 LiveRoom liveroom | 核心通用层、其他 | accept |
| 306 | `0a931f51ff9c60508a2904d439dd9831f9f16041` | 2026-10-02 | refactor(layout): 站点适配器从 core/site 提到 lib/platforms | 核心通用层、其他 | accept |
| 307 | `6cb0a480f119261ad4a04e862578eec8508ed648` | 2026-10-02 | refactor(layout): common 下的共享设施并入 core | 核心通用层、工具与策略脚本、其他 | accept |
| 308 | `ea2ac20998f0ab2c75b38d27b8ee2bdfe2b54c3d` | 2026-10-02 | refactor(layout): 服务层与平台层各归其位 | 启动与路由、核心通用层、其他 | accept |
| 309 | `78621173afee6a0e711dd6d15ea8016e87baea94` | 2026-10-02 | refactor(layout): 应用级桶文件合并进 core/index，common 目录消失 | 启动与路由、核心通用层、工具与策略脚本… | accept |
| 310 | `9ca39b2db0b86558b2a01c9824961eee331fc890` | 2026-10-02 | refactor(layout): 清掉顶层散目录，站点专属工具归位 platforms | 启动与路由、核心通用层、工具与策略脚本… | accept |
| 311 | `0b23cbb8fcd364402f6437b18fbcd9bc5b49bca8` | 2026-10-02 | fix(settings): 字体设置启动早期刷新主题崩溃 —— GetRoot 未挂载时跳过 | 其他 | accept |
| 312 | `ecc931b371cd64e2683a1a2846426d5054df7752` | 2026-10-02 | fix(lifecycle): Windows 画中画失焦不再武装返回刷新 | 其他 | accept |
| 313 | `b2cca41c72823a7467100aa116547f59513303e2` | 2026-10-02 | fix(danmaku): 画中画弹幕随窗口放大成比例缩放 | 核心通用层 | accept |
| 314 | `94ced49d702e59ef746c81e145c045abe157f7cc` | 2026-10-02 | refactor(danmaku): 删除小窗弹幕独立配置 —— 合并进主弹幕设置 + 比例系数 | 核心通用层、资源与翻译、其他 | accept |
| 315 | `f9e03f4466803df34ad56e14a535d9e9c333a72f` | 2026-10-02 | feat(floating): 小窗控件按输入方式分叉，并支持拖角改尺寸 | 其他 | accept |
| 316 | `2d2ad2039ed53fafbf5c18c7416509563db061f3` | 2026-10-02 | feat(danmaku): 补齐 flame_barrage 缺失配置 + tap-to-hold 按住定住弹幕 | 资源与翻译、其他 | accept |
| 317 | `06eac5364d864b5944f814736ddf525c9c37bbe8` | 2026-10-02 | fix(live): 小窗回直播间崩溃 —— 会话种子的 sourceQueryPolicies 类型不对 | 其他 | accept |
| 318 | `582e355f72af952a745dd3a30f7e22450b6a6fd2` | 2026-10-02 | feat(settings): 画中画尺寸设置 —— 基准尺寸/最小宽高三条滑条 | 资源与翻译、其他 | accept |
| 319 | `d629b8b7814d206d46a62fd46982dd607aba8d79` | 2026-10-02 | refactor(danmaku): hideDanmaku 成为唯一显示开关 —— 删除 enableDanmakuDisplay/enablePipDanmaku | 独立功能页、其他 | accept |
| 320 | `d819a243bb961ffd544e6400d56fd28d8c11acd6` | 2026-10-02 | refactor(layout): 模块目录按职责分家 —— 直播域进 modules/live，应用功能进 features | 独立功能页、启动与路由、核心通用层… | accept |
| 321 | `4bfd8a33e31457da5dbb4c4fbd0c1f36a9377336` | 2026-10-02 | refactor(layout): live_play 收进 modules/live/playback —— 直播播放与其他直播域同层 | 独立功能页、启动与路由、核心通用层… | accept |
| 322 | `d9a4eb922be2e86dea48fc3e319c6ac32daed25d` | 2026-10-02 | refactor(naming): 文件与类名按 TV 词汇归一，清掉三个无人引用的孤儿设置页 | 独立功能页、启动与路由、核心通用层… | accept |
| 323 | `501fc3d76e4a5a4df6de0500ac98000e08c9792a` | 2026-10-02 | refactor(layout): 接口层改名 contracts，刷新指示器归位 widgets | 独立功能页、启动与路由、核心通用层… | accept |
| 324 | `3ed6bafee299a89a0add9bd08319fbbe6a2eb7a0` | 2026-10-02 | refactor(layout): recorder 收进 features —— lib 顶层只留分层目录 | 独立功能页、启动与路由、工具与策略脚本… | accept |
| 325 | `b1b98d84765330ff91a023cf67cd99021c89f857` | 2026-10-02 | refactor(layout): services 层的四类文件归位到它们的真实归属 | 独立功能页、核心通用层、其他 | accept |
| 326 | `1c4a971bd44fb872fd942965c1b50e431350d890` | 2026-10-02 | refactor(player): 收掉四个单文件子目录 —— player 只剩 core/kernel/models/utils | 启动与路由、其他 | accept |
| 327 | `5ef5a29b85ff53c28681ca447d7c2e978ff4d605` | 2026-10-02 | feat(wallpaper): 迁移 TV 的应用背景功能 —— 壁纸/动态壁纸/纯色渐变 + 解码器让位 | 独立功能页、核心通用层、工具与策略脚本… | accept |
| 328 | `fbbccf3695760d57c113dc561fa26bac6e89383c` | 2026-10-02 | refactor(platforms): 每个站点的弹幕实现回到自己目录 —— core/danmaku 只留空实现 | 其他 | accept |
| 329 | `8a78ef81f10587d78220012e0f49663bfb293007` | 2026-10-02 | refactor(layout): 去掉 modules 层 —— 直播业务并入 features/live | 独立功能页、启动与路由、核心通用层… | accept |
| 330 | `1e1cd8ad19b4db75b1742c0fc4366e465e7c248d` | 2026-10-02 | refactor(core): 拆掉 core/plugins —— 14 个"插件"按真实职责归位 | 独立功能页、启动与路由、核心通用层… | accept |
| 331 | `2d286bc0047ed9d5ad2cbdd302ec86dc039a29ea` | 2026-10-02 | refactor(router): 24 个 <页面>_binding.dart 合成 app/router/page_bindings.dart | 独立功能页、启动与路由 | accept |
| 332 | `69316519e9540f4cad8051395344eb8fe4fc90dc` | 2026-10-02 | refactor(hygiene): 碎文件合并与命名纠偏 —— 12 个文件删除、7 个改名、9 个并入宿主 | 独立功能页、启动与路由、核心通用层… | accept |
| 333 | `4ec64e9e37919c0c02a691ae5d4cb67288366c1b` | 2026-10-02 | refactor(core): 拆掉 core/common 与服务层 utils —— 按网络/日志/流/存储/链接/发布分层 | 独立功能页、启动与路由、核心通用层… | adapt |
| 334 | `8a5bd7c80c6edc19d684e2577e492341ed52e4ad` | 2026-10-02 | refactor(player): base 改名 pagination，player/utils 按呈现与 mpv 分开 | 独立功能页、启动与路由、核心通用层… | accept |
| 335 | `276fae8adf9be96f2edfba4182b5e394782529e2` | 2026-10-02 | refactor(layout): 合回切过头的目录 —— 单文件子目录并入所属业务域 | 独立功能页、核心通用层、其他 | accept |
| 336 | `f4a5f7b6c8e397591fb945781ab6a75f2b5721ad` | 2026-10-02 | refactor(domains): 建 domains 层 —— 34 个站点适配器进 domains/live/data/platforms | 直播域、独立功能页、启动与路由… | accept |
| 337 | `5e74893f9f3eadc0bad1cf723881f2a1f7e003eb` | 2026-10-02 | refactor(architecture): 落地分层架构 —— App/Core/Domains/Features | 播放器内核、录制域、直播域… | accept |
| 338 | `77895fa701e5958b5d2569728e3956307f1a072d` | 2026-10-02 | refactor(architecture): core 设置门面去掉业务依赖 —— Cookie 存储与 IPTV 设置归位 | 直播域、IPTV 域、账号域… | accept |
| 339 | `c6a14115fc7d01a223d03a7f03296e44af1fb2be` | 2026-10-02 | refactor(architecture): core 去掉业务 UI 与实现依赖 —— 改走 Core 端口 | 直播域、独立功能页、启动与路由… | accept |
| 340 | `6244a758dda928d5b8ca5641cbf4ee03e787248e` | 2026-10-02 | refactor(architecture): core 去掉 App 与跨层实现依赖 —— 启动交接/退出/快照改走端口 | 直播域、独立功能页、启动与路由… | accept |
| 341 | `7c2cdf280a028310315a5d5960aab47f69f9b32f` | 2026-10-03 | refactor(architecture): 播放输入类型与官方分类判定归位 —— core 反向依赖 61 -> 58 | 播放器内核、直播域、启动与路由… | accept |
| 342 | `d154377d5abbd6ee7082f92099843fcdc34da5fe` | 2026-10-03 | refactor(architecture): 直播平台契约下沉 Core —— 跨域反向依赖 58 -> 49 | 录制域、直播域、IPTV 域… | accept |
| 343 | `48b84ad41b716664984f524afb732317d60b04fa` | 2026-10-03 | refactor(architecture): FFmpeg FLV 中继与上游代理回调归 Core —— 跨域 49 -> 47 | 录制域、直播域、启动与路由… | accept |
| 344 | `b7089bdf05f92e44caf0726840eac43c9adc829e` | 2026-10-03 | refactor(architecture): 错域文件归位 —— DouyuUtils 与 IPTV 适配器 —— 跨域 47 -> 40 | 直播域、IPTV 域、账号域… | accept |
| 345 | `bb56c5a61b336a2d43f084d034a70ac5127c1b57` | 2026-10-03 | refactor(architecture): 录制按钮归 recorder 域 —— 跨域 40 -> 38 | 录制域、直播域 | accept |
| 346 | `20817480dd66257766416a3970bc161f25ad16a4` | 2026-10-03 | chore(architecture): 校验脚本成为 CI 门禁 —— 登记 38 处既有耦合，卡住新增 | 工作流、工具与策略脚本 | accept |
| 347 | `3ac0012d845897994b5590a0f4514c9a9ae67eb9` | 2026-10-03 | refactor(architecture): 新建 shared 共享层 —— 站点适配器与平台契约上移 —— 跨域 38 -> 21 | 站点适配器与平台契约、录制域、直播域… | accept |
| 348 | `e1475e9aa4ee7b4db9f840ba40298246684d9147` | 2026-10-03 | chore(architecture): 门禁拒绝陈旧基线，并更新过时的目录图 —— ledger 38 -> 21 | 工具与策略脚本、仓库元数据 | accept |
| 349 | `b247e631b2dac54ce8d978f0e1754405f46a1b6c` | 2026-10-03 | fix(architecture): Niconico master 读取器改为调用时解析 —— 消除初始化顺序依赖 | 直播域 | accept |
| 350 | `07bd2a5c10702a56c4656aa8c50276bd8e9dd006` | 2026-10-03 | refactor(platforms): 弹幕相关方法回到站点自己 —— 站点自包含（弹幕切片） | 站点适配器与平台契约、直播域、IPTV 域 | accept |
| 351 | `56a379b0dfab343d78267a28e5729a31a874657c` | 2026-10-03 | refactor(platforms): 官方房间链接回到站点自己 —— 站点自包含（外部打开切片） | 站点适配器与平台契约、直播域 | accept |
| 352 | `7285eb625079efdc7f3a1d599db91ed689d664bc` | 2026-10-03 | fix(floating): 悬浮小窗的关闭按钮停掉播放 —— 恢复被重构丢掉的收尾 | 播放器内核、直播域 | accept |
| 353 | `d8b8719f349234199634940b4a03238fa3996025` | 2026-10-03 | feat(theme): 内置 MI Sans 设为全局默认字体 | 独立功能页、核心通用层、设置与持久化… | accept |
| 354 | `9a845e69d11b7fadb8d3ee6c897d70a5c360cc11` | 2026-10-03 | feat(pip): Windows 小窗可解锁比例 —— 高度/宽度可单独调整 | 播放器内核、独立功能页、设置与持久化… | accept |
| 355 | `e96878ae39935e469e11082d7c7344800ae4973b` | 2026-10-03 | feat(pip): 小窗最小尺寸可调 + 进入小窗时记录实际生效策略 | 播放器内核、设置与持久化 | accept |
| 356 | `2ee3ee8fd6127059b1be069996b59c2bfea0aded` | 2026-10-03 | fix(danmaku): 小窗弹幕比例只做缩小，且设置真正生效 | 直播域、设置与持久化、资源与翻译 | accept |
| 357 | `873344eb5bf82a977619f07bf294843807b61af8` | 2026-10-03 | fix(danmaku): 小窗/画中画弹幕补上「距离顶部/底部」内缩 | 直播域 | accept |
| 358 | `a4eeb7adbe88babc625a75c7540eee009e687099` | 2026-10-03 | fix(danmaku): 竖屏弹幕策略与其余遗漏项补到小窗/多画面 | 直播域 | accept |
| 359 | `234df47a46e4a5f019e9c2fc668d48d8775c162d` | 2026-10-03 | fix(fullscreen): 全屏进出交给内核呈现链 —— 从全屏进入画中画不再保留全屏状态 | 播放器内核、直播域 | accept |
| 360 | `dc7298500b0c16e05c52e11ee931277598bd8f0e` | 2026-10-03 | feat(pip): 小窗几何按横竖屏各记一套 —— 恢复被合并丢掉的竖屏几何 | 播放器内核、启动与路由、设置与持久化… | accept |
| 361 | `753bbbb7e116492af08ea2cfebd629333b368fed` | 2026-10-03 | fix(multiview): 多画面有声无画与没有弹幕 | 直播域 | accept |
| 362 | `e437b5bd830388b246d5093cf47852862be03ffd` | 2026-10-03 | feat(floating): 应用内悬浮窗记住位置与尺寸（横竖屏各一套） | 播放器内核、独立功能页、启动与路由… | accept |
| 363 | `03957c271d128ea52d985e32f9f3d62289273c13` | 2026-10-03 | fix(player): 源提交代次从未递增 —— 切换清晰度/线路的界面永不停留 | 直播域 | accept |
| 364 | `fc637dd53e62bc5403dbf1da7a15c73df3582d6e` | 2026-10-03 | fix(play_other): 换台面板回到大卡布局 —— 封面固定 16:9，放不下就滚动 | 直播域 | accept |
| 365 | `db5594b990e0a2233c7a2c7ddb9e5a5a23975852` | 2026-10-03 | fix(wallpaper): 墙纸网格在 Obx 内读取响应式值 —— 修复背景设置页 ObxError | 壁纸域 | accept |
| 366 | `555ed5d3d4a806fadcc404c3b5d80206e1a6ba0e` | 2026-10-03 | fix(play_other): 换台面板恢复双形态 —— 窄面板一行一个主播，宽面板才是封面卡片 | 直播域 | accept |
| 367 | `5d29713b8bc539b28de74bdbcf4363d7e2fa0268` | 2026-10-03 | feat(wallpaper): 随机图源数据层 —— 源表、随机取图与字节入库 | 壁纸域、核心通用层、资源与翻译 | accept |
| 368 | `813123a65446a3d2fc332fbef79d150dab486680` | 2026-10-03 | feat(wallpaper): 背景设置改为分入口 + 自动续页的网格 + 全屏预览 | 壁纸域 | accept |
| 369 | `b2bafe23a3305a123e86bdab83103d6779231082` | 2026-10-03 | docs: 记录背景设置随机图源迁移与分页/预览重构 | 文档 | accept |
| 370 | `26ca835b4b17f7e279128e5d762ce3f23981a153` | 2026-10-03 | fix(theme): 全局主题查找不再在重建空窗里崩 —— 标题栏与 AppTextStyles | 核心通用层 | accept |
| 371 | `8e52f167f8588c6218b47df73547bcec3981d788` | 2026-10-03 | fix(wallpaper): 背景层不再在有无壁纸之间换树形 —— 导航子树不整棵失活 | 壁纸域 | accept |
| 372 | `907a34d353c62ca657523a7b264d6b9f304b9744` | 2026-10-03 | feat(bilibili): 摘取 4.x 的轮播房支持与心跳人气修正 | 站点适配器与平台契约、直播域、核心通用层… | accept |
| 373 | `489aaf85949bae4e98a2aed93e965584d930f09f` | 2026-10-03 | feat(douyu): 摘取 4.x 的下播结束弹幕与分区图标兜底 | 站点适配器与平台契约、文档 | accept |
| 374 | `ac69fc2c113399e49b1c58a4e8c332f4841b8f2e` | 2026-10-03 | fix(huya): 搜索与分组树补上 User-Agent —— 否则 403 Not allowed | 站点适配器与平台契约、文档 | accept |
| 375 | `b1d10539261984c5f0dbb219c339f72d2e889e30` | 2026-10-03 | feat(wallpaper): 分页改用应用统一分页条，预览页控件改为弹窗，子页透明 | 壁纸域、资源与翻译、文档 | accept |
| 376 | `50fe8ffe913131ce83183b67d7306c0d276a0955` | 2026-10-03 | feat(douyin): 摘取 4.x 的直播判定兜底、游戏分区、精确在线人数与聊天时间 | 站点适配器与平台契约、文档 | accept |
| 377 | `5a13f924b24106de050232f205901731830fc059` | 2026-10-03 | feat(kuaishou): 摘取 4.x 的 H.265 独有档位与详情标题兜底 | 站点适配器与平台契约、核心通用层、文档 | accept |
| 378 | `654acc89e5c5722ec23bd769ae02f80e15bf3e8e` | 2026-10-03 | feat(core): 摘取 4.x 的不可见占位字符清理 —— 房间文本与弹幕文本 | 核心通用层、文档 | accept |
| 379 | `694b16d139b5b7578fff18c93fb34c20b7efc7b0` | 2026-10-03 | feat(live): 平台选择器统一带平台 logo —— 关注 / 热门 / 搜索 与分区一致 | 直播域 | accept |
| 380 | `08db50b3b2e1ca310dc9c0a0a763f0e41a628d30` | 2026-10-03 | feat(yy): 摘取 4.x 的分区名预置、默认标题去后缀与弹幕热度 | 站点适配器与平台契约、文档 | accept |
| 381 | `d8d47d058487188f135246cd1061c290eaa7ffa0` | 2026-10-03 | fix(cc): 摘取 4.x 的「【重播】」判定与推荐卡分区字段 | 站点适配器与平台契约、文档 | accept |
| 382 | `8d3564ce51e92f047d9d906d03a98f9d09bf0bd7` | 2026-10-03 | feat(live): 站点分类平铺按站点表决定 —— 同步 TV 的 area_display_config | 直播域、测试 | accept |
| 383 | `2f57b28d9336d4332f28a92990ab100562c15600` | 2026-10-03 | feat(twitch): 摘取 4.x 的图片直连、媒体不带登录 Cookie 与详情字段 | 站点适配器与平台契约、直播域、文档 | accept |
| 384 | `b3e26747da66df6f1e597c95e519b296684207d9` | 2026-10-03 | feat(soop): 摘取 4.x 的 HTML 实体解码与搜索分区字段 | 站点适配器与平台契约、文档 | accept |
| 385 | `cba9fbd3a25f3c8b50f94a31750c5496207ad815` | 2026-10-03 | feat(chzzk): 摘取 4.x 的频道链接、搜索页长/关键词与未开播判定 | 站点适配器与平台契约、文档 | accept |
| 386 | `dd1fa503485c061961e15b860fadaa892026ffdd` | 2026-10-03 | fix(wallpaper): 背景只在背景页可见 —— 页面透明改在树上生效，贯穿整个 App | 壁纸域、测试、文档… | accept |
| 387 | `1c3f4500167f2c1e0062dad41307c8fc274007e2` | 2026-10-03 | feat(kugoulive): 摘取 4.x 的播放限制根因、卡片状态与标题/公告 | 站点适配器与平台契约、文档 | accept |
| 388 | `17fb0611b8a3ddab023a7f679ee9b50efb675ccf` | 2026-10-03 | ﻿fix(wallpaper): 进入页面闪一下 —— 过渡期的 surface 底衬在壁纸下改为透明 | 壁纸域、测试 | accept |
| 389 | `3c3322df16a8eea44e18731764fee640db9f6299` | 2026-10-03 | feat(pandalive): 摘取 4.x 的 IVS 线路租约与录播重播判定 | 站点适配器与平台契约、文档 | accept |
| 390 | `0c84c3471c376b5fb06313d0be5a10f2a8f9acc8` | 2026-10-03 | ﻿feat(live): 播放页背景跟随壁纸 —— 窗口态让出 canvas，全屏/小窗保持黑底 | 直播域、壁纸域、核心通用层… | accept |
| 391 | `7c1b9c0a45d0bebf7cf1ee3f44e392054127f2f8` | 2026-10-03 | feat(picarto): 摘取 4.x 的搜索卡片简介字段 | 站点适配器与平台契约、文档 | accept |
| 392 | `04bbda9dc6474469b8a216c921805bd736e67bd7` | 2026-10-03 | docs(ledger): niconico 评估结论（房间即主播模型与 NDGR 评论，留待后续批次） | 文档 | accept |
| 393 | `a3a0d2dfaa9e58b9ab72f872d876ddfa9427ba3c` | 2026-10-03 | feat(missevan,kilakila): 摘取 4.x 的单档线路回退与下播判定 | 站点适配器与平台契约、文档 | accept |
| 394 | `5e26c6933c6080439535fb4a541f42980c74e094` | 2026-10-03 | feat(weibo,steambroadcast): 摘取 4.x 的快照状态与头像规则 | 站点适配器与平台契约、文档 | accept |
| 395 | `531bcae87da2b2f212c758f3b22694d5b9ec90c1` | 2026-10-03 | feat(liveme,showroom,fc2live): 摘取 4.x 的未开播状态与观众数口径 | 站点适配器与平台契约、文档 | accept |
| 396 | `3e5a99b7de194e66716c446136acb1ca177ff388` | 2026-10-03 | feat(bigo,sixroom): 摘取 4.x 的封面截图与搜索卡片状态 | 站点适配器与平台契约、文档 | accept |
| 397 | `df2b67b710ec3a0357d1ac440dfcb7854d9060d9` | 2026-10-03 | feat(seventeenlive,acfun): 摘取 4.x 的链接主机/搜索关键词与「全部」分区 | 站点适配器与平台契约、文档 | accept |
| 398 | `286661099d5cbd89fcd0515f1627e04b704f66db` | 2026-10-03 | feat(baidulive,twitcasting): 摘取 4.x 的 http 播放主机与直播 telop 标题 | 站点适配器与平台契约、文档 | accept |
| 399 | `a02bcba840a1eea18b2be8ebc900e39491b3711d` | 2026-10-03 | feat(jdlive,looklive,inke): 摘取 4.x 的封禁状态、占位名清理与封面来源 | 站点适配器与平台契约、文档 | accept |
| 400 | `f54d11d532d80b597eadc7231297719c1454f5aa` | 2026-10-03 | feat(xiaohongshu): 摘取 4.x 的房间不存在判定与 App 深链参数 | 站点适配器与平台契约、文档 | accept |
| 401 | `0152eb04be7c65d212a4af4d39133a6a41f0cd1e` | 2026-10-03 | feat(tiktok): 摘取 4.x 的短链搜索与容错解析 | 站点适配器与平台契约、文档 | accept |
| 402 | `a7783b525a401bd8afe2a490713462a7eb8bbfc8` | 2026-10-03 | feat(backup,danmaku,player): 备份模块勾选、弹幕海量模式与播放器内核整理 | 播放器内核、直播域、独立功能页… | accept |
| 403 | `15c72a90991a5a646b6545912cfbda885b767200` | 2026-10-03 | feat(model,tiktok): 补 startedAt/restriction 模型与 TikTok 受限直播口径 | 站点适配器与平台契约、直播域、核心通用层… | accept |
| 404 | `54b4d92d88822ba953abc11efefc4cf06066ed03` | 2026-10-03 | feat(wallpaper): 壁纸延伸到标题栏与左侧导航栏 —— 顶部/左边也铺满 | 壁纸域、独立功能页、核心通用层… | accept |
| 405 | `35bfc0746d06bdd48c89a9117b5b4eae603433ec` | 2026-10-03 | fix(liveme): 摘取 21-5/21-8 受限直播口径与开播时间 | 站点适配器与平台契约、文档 | accept |
| 406 | `71e33de5a31afdcccc060e6ab5997d1f8feca5ba` | 2026-10-03 | fix(fc2live): 摘取 26-9 受限直播的限制种类与开播时间 | 站点适配器与平台契约、文档 | accept |
| 407 | `f9b97fa5a48ef2f3737f6224ee9c35c36c39c953` | 2026-10-03 | fix(bigo,jdlive): 摘取受限直播的限制种类（24-2 / appOnly） | 站点适配器与平台契约、文档 | accept |
| 408 | `f641c8514e3c3e86d19dd4f880428ef11d96723d` | 2026-10-03 | feat(wallpaper): 卡片/分页条/顶栏等组件底色跟随壁纸 —— 不再是一块白 | 壁纸域、独立功能页、核心通用层… | accept |
| 409 | `23af1c8fc29806387f041a9d97b77d62a5c8e44a` | 2026-10-03 | fix(weibo,showroom,kuaishou): 摘取受限直播状态与限制种类（18-4 / 19-x / unplayable） | 站点适配器与平台契约、文档 | accept |
| 410 | `bf606692f9c6278ebe335d0a0bc7d9e5ee64f5f3` | 2026-10-03 | fix(wallpaper): 弹窗/下拉菜单不再透出壁纸 —— 只洗页面 chrome | 壁纸域、测试、文档 | accept |
| 411 | `03269a431ad8c29493480bf7f4f43e4a3ddec238` | 2026-10-03 | fix(picarto,twitcasting): 摘取私密/密码/不可播的限制种类 | 站点适配器与平台契约、文档 | accept |
| 412 | `937f31da90fb4f7b04ec009043d9e9027f413b85` | 2026-10-03 | fix(seventeenlive): 摘取 premiumContent 锁定的限制种类 | 站点适配器与平台契约、文档 | accept |
| 413 | `4db5394477ce469a5e5d812cc472781faa1eca96` | 2026-10-03 | fix(steambroadcast): 摘取 missing_subscription 与 is_replay 的状态/限制 | 站点适配器与平台契约、文档 | accept |
| 414 | `185ff91a0629e77e8539f9c3a5ae85c6b851fad6` | 2026-10-03 | fix(sixroom): 摘取私密/黑屏房间的限制种类 | 站点适配器与平台契约、文档 | accept |
| 415 | `0a3749d373d95c91e1bd8876caf8feb2e20d7e3f` | 2026-10-03 | docs(ledger): 记录范围决定——不新写弹幕引擎，只同步站点侧弹幕显示 | 文档 | accept |
| 416 | `2a3a713a5d666e4ac8e42789890ae0f561733726` | 2026-10-03 | fix(wallpaper): 页面切换不再闪白/闪黑 —— 改用淡出后再淡入的过渡 | 壁纸域、测试 | accept |
| 417 | `469e9926a03a5884e62407c4df774d05d5b6dcb5` | 2026-10-03 | fix(acfun): 摘取付费节目的限制种类 | 站点适配器与平台契约、文档 | accept |
| 418 | `463edd38aded1f1f99c332df1202d2205fda22b6` | 2026-10-03 | fix(baidulive): 摘取付费/禁止/封禁的限制种类 | 站点适配器与平台契约、文档 | accept |
| 419 | `7f7b5d2888d591abe45ba24b4a3e8337332f85a6` | 2026-10-03 | fix(wallpaper): 卡片改深、两页观感一致 —— 加一个卡片专用透明度 | 壁纸域、核心通用层、测试… | accept |
| 420 | `bbc0ef44c5d9c972f03d4e68ca018d28c71dc978` | 2026-10-03 | feat(cc): 摘取开播时间与"有档位即无限制" | 站点适配器与平台契约、文档 | accept |
| 421 | `4cb814033208cf458e445dd0f2fca398b0e19fe0` | 2026-10-03 | feat(seventeenlive): 摘取 33-7 的开播时间 | 站点适配器与平台契约、文档 | accept |
| 422 | `ec327f40624ba6a1eabe3ff5ce98d547e7d9f980` | 2026-10-03 | feat(twitch): 摘取开播时间 | 站点适配器与平台契约、文档 | accept |
| 423 | `183cd2ab633fb562a951d6ecd07a9e0bcecdc738` | 2026-10-03 | feat(acfun): 摘取 10-3 的开播时间 | 站点适配器与平台契约、文档 | accept |
| 424 | `0524c901f7708f9556ce6c23040ac1e357c275b4` | 2026-10-03 | fix(wallpaper): 没设壁纸时背景设置各页底色不同 —— 去掉写死的透明 Scaffold | 壁纸域 | accept |
| 425 | `5d187d7cafb79fe6ea0cc622022d1b68df9a26f2` | 2026-10-03 | feat(douyu): 摘取开播时间 | 站点适配器与平台契约、文档 | accept |
| 426 | `c23cff07e5ecea2f992ff58158e5618b35cd6eda` | 2026-10-03 | feat(douyin): 摘取开播时间 | 站点适配器与平台契约、文档 | accept |
| 427 | `f7c61d4f0016eb0249fb88dae1fbe487b06f37b7` | 2026-10-03 | refactor: 调整导入顺序以提高代码可读性 | 站点适配器与平台契约、播放器内核、直播域… | accept |
| 428 | `ffd53aeec72cf6eb9116d8474b49b16c60e9292a` | 2026-10-03 | feat(showroom): 摘取 current_live_started_at 开播时间 | 站点适配器与平台契约、文档 | accept |
| 429 | `adcfd0c0633aea3b01899dfbb32487b5916feb16` | 2026-10-03 | feat(inke): 摘取 start_time 开播时间 | 站点适配器与平台契约、文档 | accept |
| 430 | `02fd06363e159a506511907cc1654c245c592924` | 2026-10-03 | feat(huya): 摘取搜索卡片的付费标记 | 站点适配器与平台契约、文档 | accept |
| 431 | `7e90a15e71ebf85279ccc9f48a276c284c773072` | 2026-10-03 | fix(favorite): 刷新失败的日志只报"哪个直播间" —— 不再每个房间一串堆栈 | 直播域、测试 | accept |
| 432 | `7f31d7756058d9860d8abb597cb7614ec6527a68` | 2026-10-03 | feat(bilibili): 摘取付费房限制 | 站点适配器与平台契约、文档 | accept |
| 433 | `0217414904edb325a4e1bb093137fcee8ea78750` | 2026-10-03 | feat(bilibili): 摘取详情开播时间 | 站点适配器与平台契约、文档 | accept |
| 434 | `41ec1fcb32ac9cf03847aae1c213012aa30411bf` | 2026-10-03 | polish(favorite): 失败条目合并成一组括号 —— `小明（douyin/123456，TimeoutException）` | 直播域 | accept |
| 435 | `b0afe3a554e52f81e595697be84c29414906b777` | 2026-10-03 | docs(ledger): B 站弹幕公告已有回执；撤回属跨层改动并记录原因 | 文档 | accept |
| 436 | `fcdbd588544839c460db1bc4fbfef7113699246f` | 2026-10-03 | fix(danmaku): 打码昵称不再参与屏蔽匹配 | 直播域、文档 | accept |
| 437 | `6e5b10da942f4a92fa78490f42d364f5a455ee5d` | 2026-10-03 | docs(ledger): 记录 84b9fe205 不适用（本仓无该运行时，快手轮询已是单定时器） | 文档 | accept |
| 438 | `dcfe7aeb201df7c690196b2e3857e514d6dfd954` | 2026-10-03 | docs(ledger): 批次2 核查表——8 个已有引擎站点的弹幕改动分类 | 文档 | accept |
| 439 | `497e20c80287825902d846479f9846ee56f8e3ac` | 2026-10-03 | docs(ledger): 快手表情图片需跨层（LiveMessage.emotes），修正批次2 分类 | 文档 | accept |
| 440 | `89248f0ff16d5f085f3cbb5210e2e112e8c47e71` | 2026-10-03 | feat(model): 新增 LiveMessageType.retraction 与 LiveRetraction（弹幕撤回的公共模型） | 核心通用层 | accept |
| 441 | `0533df81b51cc003cd5733efa8735c595a8f9103` | 2026-10-03 | feat(bilibili): 解析弹幕撤回（RECALL_DANMU_MSG / 醒目留言删除） | 站点适配器与平台契约 | accept |
| 442 | `db09fc212ea67fd39750b4d60f92f8826a66271a` | 2026-10-03 | feat(danmaku): 撤回接入显示层，打通整条链路 | 直播域 | accept |
| 443 | `4966ca1ce51b6909d71a44b21d5f4c0c0b9e18da` | 2026-10-03 | feat(danmaku): 撤回打通到画面弹幕（引擎侧新增按条撤回） | 直播域、依赖与供应链、文档 | accept |
| 444 | `11a47144e6ef338212fe8c8aa278944fac6ef93a` | 2026-10-03 | feat(danmaku): 平台礼物进弹幕列表展示（B 站 SEND_GIFT/COMBO_SEND/GUARD_BUY） | 站点适配器与平台契约、直播域、文档 | accept |
| 445 | `43540cc106be34a952b4afcfdb0af2243a1b291e` | 2026-10-03 | feat(model): LiveMessage.emotes 与 LiveEmote（消息里的表情图片） | 核心通用层 | accept |
| 446 | `9fb1ef1da11aa850f53c3e1dca057240d8c2d9a4` | 2026-10-03 | feat(bilibili): 解析聊天里的贴纸与内联表情 | 站点适配器与平台契约 | accept |
| 447 | `c4699764d7b7878190462190bfc22fd30aaf8c73` | 2026-10-03 | feat(danmaku): 弹幕列表渲染消息自带的表情图片 | 直播域 | accept |
| 448 | `f587c26a30f9e9428c9129b4f554ea777c8a59cb` | 2026-10-03 | feat(danmaku): 画面弹幕渲染消息自带的表情图片 | 直播域 | accept |
| 449 | `c217b86bcf005e65d0bd12479a1e6c471d02eaff` | 2026-10-03 | feat(kuaishou): 弹幕参数带表情表，评论里的编码填进 emotes | 站点适配器与平台契约 | accept |
| 450 | `dffed3f692cacd0eea939ea2f34907c4a87cd496` | 2026-10-03 | feat(kuaishou): 从房间页取表情表并挂进弹幕参数 | 站点适配器与平台契约、文档 | accept |
| 451 | `6e79b8bda95202e3deafeeca32f4665b91a45328` | 2026-10-03 | feat(danmaku): 平台公告进弹幕列表（B 站 WARNING / CUT_OFF） | 站点适配器与平台契约、直播域、核心通用层 | accept |
| 452 | `133725ed71ee7b3519f2da3d88572a37d41f5321` | 2026-10-03 | fix(huya): 结束直播通知结束这一路弹幕（C-10） | 站点适配器与平台契约 | accept |
| 453 | `07a91cd11667a74f674c1b911307a11482160c78` | 2026-10-03 | docs(ledger): B 站轮播 play_time 起播偏移的实施方案（三层五步） | 文档 | accept |
| 454 | `4291990b6ba5824196f04270a24714cbb076bbc5` | 2026-10-03 | feat(bilibili): 轮播起播位置从站点解析到播放层（第 1-3 步） | 站点适配器与平台契约、直播域、文档 | accept |
| 455 | `425d94aebe44875ebaff1f66c81e7c97fab6c794` | 2026-10-03 | docs(ledger): 轮播起播偏移第 4-5 步的障碍——本仓播放层没有暴露 seek | 文档 | accept |
| 456 | `631ca6e221c94b30efac5bcfa6b9e68432fd2191` | 2026-10-03 | docs(ledger): ③ 身份模型的实测现状与实施方案 | 文档 | accept |
| 457 | `764c25c571de5001f285719d6154084adfb643d2` | 2026-10-03 | docs(ledger): ③ 复评——YouTube 功能已等价，建议只做 niconico | 文档 | accept |
| 458 | `abb4c726981cb7d8948f1ee60e90c9fbda94f13a` | 2026-10-03 | feat(niconico): 摘取 17-2 的节目链接形态（http / sp.live / nico.ms） | 站点适配器与平台契约 | accept |
| 459 | `bb1f6fbae2d45e09bbcd0f0ed0adc096d2c4dd0d` | 2026-10-03 | feat(niconico): 主播链接可打开（房间身份仍是节目号） | 站点适配器与平台契约、直播域 | accept |
| 460 | `c0477ed6c1b25ead2e75ce198e69f9a56187d7eb` | 2026-10-03 | docs(ledger): ③ niconico 的剩余部分就是身份翻转本身（无中间态） | 文档 | accept |
| 461 | `e38021e6eaee46d2a41a4bec8f1048228ba26169` | 2026-10-03 | docs(ledger): 同步状态总览（收尾核对） | 文档 | accept |
| 462 | `b087ee901eb35b568ec91bcedd2c259428f4c6f3` | 2026-10-03 | chore: update releases.json [skip ci] | 资源与翻译 | accept |
| 463 | `da60297a86d279fb6ec54683b2b66d79d84a67e9` | 2026-10-03 | docs(ledger): 用户决定 A——就此收尾（不做身份翻转，轮播偏移停在 3/5 并记账） | 文档 | accept |
| 464 | `41dfe0616a993badac92d56532fb4207be4571ea` | 2026-10-03 | feat(bilibili): 粉丝牌解析与列表展示（上游 2eea8022a 前半） | 站点适配器与平台契约、直播域 | accept |
| 465 | `38ef726b5beb8c924c8db9cc9f4661ed7d5da689` | 2026-10-03 | docs(ledger): 未同步清单（机械盘点 204 条站点层提交 + 逐项核实） | 文档 | accept |
| 466 | `7c8b7f59908c404215ea1b638b4925f50bd12f6e` | 2026-10-03 | feat(twitch): CLEARMSG/CLEARCHAT 撤回；并修好按用户撤回从来不命中 | 站点适配器与平台契约、直播域、核心通用层… | accept |
| 467 | `360f2aff561105b57edf6566f8d2bd41a546b681` | 2026-10-03 | feat(bilibili): 发送者头像跨层支持（上游 2eea8022a 最后一块的解析与展示） | 站点适配器与平台契约、直播域、核心通用层… | accept |
| 468 | `c2aca612bb1f634cd1fbbac8ca50abdce12f37e0` | 2026-10-03 | feat(bilibili): 弹幕列表顶部的昵称提示条（上游 2eea8022a 最后一块） | 直播域、资源与翻译、文档 | accept |
| 469 | `69137a399c57f0aed5df51bb6240e5ad3f81ecb8` | 2026-10-03 | fix(playback): TwitCasting 相对分片被当成本地路径 —— 播放前用 ingest 中继改写清单 | 直播域、依赖与供应链、测试 | accept |
| 470 | `22f659782a36daaaf41a8993377c2a51aa666b9f` | 2026-10-03 | feat(twitch): Cookie 失效时给用户提示并改用匿名（用户提示同步） | 站点适配器与平台契约、资源与翻译、文档 | accept |
| 471 | `b554dd2b7625a7d55d3b685dfa305e9282222bed` | 2026-10-03 | feat(twitch): USERNOTICE 订阅/续订/赠送/突袭/公告进弹幕区（上游 B-7 候选 3） | 站点适配器与平台契约、文档 | accept |
| 472 | `ac74b0ad413b384c1e398883f64d03800ef8c71a` | 2026-10-03 | feat(playback): HLS 输入按清单实测决定 —— 覆盖所有站点，不再只列 TwitCasting | 直播域、测试 | accept |
| 473 | `d27a56a9918cad19458f98c8da7c9871931c8ae8` | 2026-10-03 | feat(twitch): 搜索卡片带上粉丝数（上游 F-SRC-01 的七个平台之一） | 站点适配器与平台契约、文档 | accept |
| 474 | `df893309db44f93abf45e916a886706f24fd1812` | 2026-10-03 | feat(player): 播放线路的"声明图片尺寸"（上游 F.1b）跨层落地 | 站点适配器与平台契约、直播域、核心通用层… | accept |
| 475 | `099cc07e69ae16a570d6e18507da7303bc9ddbb3` | 2026-10-03 | docs(ledger): 抄下虎牙 2001314 面板结构（C-9 待实施；本仓补拉已功能正确） | 文档 | accept |
| 476 | `dbe1818cfaaadc06789a336d92e142cb7b5501ca` | 2026-10-03 | feat(player): 轮播起播位置落地——播放层 seek 通道 + 时长就绪后 seek 一次 | 直播域、文档 | accept |
| 477 | `c873e005c39022e7e968031cf9b74a8f87b747d5` | 2026-10-03 | feat(niconico): 身份翻转为"房间即主播"（上游 NiconicoApi.roomIdOf） | 站点适配器与平台契约、直播域、文档 | accept |
| 478 | `fd530a9181642b08380deb3197f133c5712abdf0` | 2026-10-03 | feat(youtube): 身份翻转为"频道即房间"（上游 4.x） | 站点适配器与平台契约、文档 | accept |
| 479 | `585558aa96ce4c59e6c1380e1db002423b1b0b9c` | 2026-10-03 | docs(ledger): 虎牙面板的落地配方（本仓 Tars API + 字段映射 + 为何先停） | 文档 | accept |
| 480 | `241996e67a6340a3d8c2ccb2d3cc3178bdd78a5c` | 2026-10-03 | docs(ledger): f12bf0f8c 握手失败钩子判为不适用（唯一消费者是 missevan 会话续期，本仓无该引擎） | 文档 | accept |
| 481 | `5061862414f7b8f7979054ecc7fe12346aedba7f` | 2026-10-03 | feat(huya): 通知自带的留言板面板直接用（上游 C-9），并补测试 | 站点适配器与平台契约、测试、文档 | accept |
| 482 | `f01ef124aafdb3423d8a37ef5178f40e8d9caab6` | 2026-10-03 | docs(ledger): 第二轮收尾核对——A/B 全部落地，剩余只有按指令排除的聊天引擎 | 文档 | accept |
| 483 | `b749c3f3ef2e1e92633b19b8d6a79a173ade2ef7` | 2026-10-03 | refactor(playback): legacy HEVC FLV 改走 FFmpeg 重封装 —— 不再在 Dart 里改 FLV 标签 | 播放器内核、录制域、直播域… | accept |
| 484 | `1990e1243c566292cf42d6455f2213451073577b` | 2026-10-03 | feat(baidulive): 移植上游的聊天引擎（M5.26，轮询消息列表） | 站点适配器与平台契约、文档 | accept |
| 485 | `0da5eb77be58a477d6b62a03d354286332157fe1` | 2026-10-03 | feat(twitcasting): 移植上游的评论引擎（M5.11） | 站点适配器与平台契约、文档 | accept |
| 486 | `49b6fa53f0ea453d793599ec2bda7c9585d534f3` | 2026-10-03 | refactor(playback): token 平台播放走 ingest 回环中继 —— 播放路径不再复用录制中继 | 直播域、核心通用层 | accept |
| 487 | `4c548315976e3cd69ff9995731b20e7c7f23465f` | 2026-10-03 | feat(sixroom): 移植上游的聊天引擎（M5.27） | 站点适配器与平台契约、文档 | accept |
| 488 | `e89c0c6fb80f537eba14785b8f9c6ae69372ecc9` | 2026-10-03 | feat(steambroadcast): 移植上游的聊天引擎（M5.23） | 站点适配器与平台契约、文档 | accept |
| 489 | `521812ae3f6bcd8df42ecbb4cb8baf49fe1ae4df` | 2026-10-03 | feat(fc2live): 移植上游的评论引擎（M5.22） | 站点适配器与平台契约、文档 | accept |
| 490 | `d1590cbbc0e49b5ff86fa6ebad78026055d22f18` | 2026-10-03 | feat(pandalive): 移植上游的聊天引擎（M5.21） | 站点适配器与平台契约、文档 | accept |
| 491 | `fabe51c1e18ea70b1dd39e3fdc4fa8f0fdaa759f` | 2026-10-03 | feat(bigo): 移植上游的聊天引擎（M5.20） | 站点适配器与平台契约、文档 | accept |
| 492 | `2fdc1d613d435c1b8b7c9e424b5f748caf6c0eb2` | 2026-10-03 | feat(showroom): 移植上游的评论引擎（M5.15） | 站点适配器与平台契约、文档 | accept |
| 493 | `d191489376f03f0b9b7d9b1d8561bf91b8226adf` | 2026-10-03 | feat(chzzk): 移植上游的聊天引擎（M5.16） | 站点适配器与平台契约、文档 | accept |
| 494 | `c3a9d9bd2abb4f6e4b594ee02c21c8dc1c90063d` | 2026-10-03 | feat(picarto): 移植上游的聊天引擎（M5.10 + B-8） | 站点适配器与平台契约、文档 | accept |
| 495 | `a46b2e5024c72259526cbbb13f02fa51e8743616` | 2026-10-03 | feat(kilakila): 移植上游的聊天引擎（M5.13 + B-10） | 站点适配器与平台契约、文档 | accept |
| 496 | `25d2000bedb0bb982f44b9f1d3139c13baa91a71` | 2026-10-03 | feat(missevan): 移植上游的聊天引擎（M5.12 + B-1/B-9） | 站点适配器与平台契约、文档 | accept |
| 497 | `ba7c5d0bbfbca37b4267c9eaeed5ab135b73539c` | 2026-10-03 | feat(seventeenlive): 移植上游的聊天引擎（M5.29 + B-14） | 站点适配器与平台契约、文档 | accept |
| 498 | `438bfc7f60f35cdad4e56ffb0f3a5cef315bddc2` | 2026-10-03 | docs(ledger): AcFun 差距分析（缺会话/票据与通用 protobuf 读写器）与 JD/LOOK/Kugou 的入口说明 | 文档 | accept |
| 499 | `fb8e2179ba65b96fbb6738967a50e5e10f8f5984` | 2026-10-03 | feat(acfun): 弹幕第一段——站点层的访客会话与票据（M5.9 / M4.10） | 站点适配器与平台契约 | accept |
| 500 | `2541b88ed09a8e26f8e8d8e6aed7373860fdcd8c` | 2026-10-03 | feat(acfun): 弹幕第二段——字段级 protobuf 读写器（M5.9） | 站点适配器与平台契约、测试 | accept |
| 501 | `7c2d9e2ba6bb4ce4e22b71a4d5928c022ce8bbf5` | 2026-10-03 | feat(acfun): 弹幕第三段——帧编解码与会话（M5.9），AcFun 打通 | 站点适配器与平台契约、文档 | accept |
| 502 | `b58eb0a175fc8818a7e23d3088377af6f8f65d6e` | 2026-10-03 | feat(jdlive): 移植上游的聊天引擎（M5.24） | 站点适配器与平台契约、文档 | accept |
| 503 | `47f7600c57853b43ce61574613a4a15f5704da7a` | 2026-10-03 | feat(looklive): 弹幕第一段——聊天服务器地址与参数（M5.28） | 站点适配器与平台契约 | accept |
| 504 | `1fc235bafc5abf677f130f413e19b73537ed1b7b` | 2026-10-03 | feat(looklive): 弹幕第二段——socket.io 0.9 引擎（M5.28），LOOK 打通 | 站点适配器与平台契约、文档 | accept |
| 505 | `2958e35a507fd224dc8c78a23544ef0475d699bf` | 2026-10-03 | feat(kugoulive): 移植上游的聊天引擎（M5.25），全部 17 站聊天引擎到齐 | 站点适配器与平台契约、文档 | accept |
| 506 | `c17d9316aa519840b3eb1c8b036461f13c79943a` | 2026-10-04 | feat(stream): 线路自带容器/编码声明 —— 取流按事实决定直连还是 FFmpeg 转封装 | 站点适配器与平台契约、直播域、工具与策略脚本… | accept |
| 507 | `85e5e0051907eb61985058d870d52294113b967e` | 2026-10-04 | feat(stream): B 站与 IPTV 声明线路容器 —— ts/fmp4/udpxy 不再被当成清单探测 | 站点适配器与平台契约、IPTV 域、测试… | accept |
| 508 | `c7298755f5bdda2ec3b6cd4a0c9dfa294fe3af55` | 2026-10-04 | feat(stream): 接上取流接线，FFmpeg 转封装与清单改写真正生效 | 直播域、启动与路由、测试… | accept |
| 509 | `0a299dd0071ce2b75cbf3bf1ee4e0d65b3d9e7f3` | 2026-10-04 | fix(tray): 热重启先释放上一代 isolate 的孤儿托盘图标 | 核心通用层、工具与策略脚本 | accept |
| 510 | `8f55b49c60955d305a945f28e2722905c8e5b044` | 2026-10-04 | fix(player): apply the player proxy to the engine, falling back to the Windows system proxy | 播放器内核、核心通用层、设置与持久化… | accept |
| 511 | `a9140e7da4874d1bfdbed44ba01081e11513042a` | 2026-10-04 | feat(player): decide the demuxer and the proxy per source instead of per engine | 播放器内核、直播域、测试… | accept |
| 512 | `e03f4d98a12edbfd97113c8c3a95fbde7559ab24` | 2026-10-04 | fix(player): stop treating a live playlist as a seekable file, and let mpv speak | 播放器内核、测试、文档 | accept |
| 513 | `c5ada971d77553e56fa0f73d2b30217f1862c16b` | 2026-10-04 | fix(player): give each mpv property exactly one owner | 播放器内核、设置与持久化、测试… | accept |
| 514 | `56eeace0b2e310c9a880ad4b8db32a1d1e21b7d4` | 2026-10-04 | refactor(stream): say what the manifest children actually are | 站点适配器与平台契约、直播域、IPTV 域… | accept |
| 515 | `86dde8f1699dac280a2a637eb8e5d6b97513217a` | 2026-10-04 | fix(stream): keep the manifest's session cookie on relayed children | 直播域、测试、文档 | accept |
| 516 | `ee6bf4c9a363d035333ed7dd97f990e6ad4529b1` | 2026-10-04 | fix(missevan): read the guest session from the whole Set-Cookie header list | 站点适配器与平台契约、测试、文档 | accept |
| 517 | `c920cc77ce9b49618c97f954c0674ea78e290bde` | 2026-10-04 | fix(playback): restore the owned-input binding my cleanup deleted | 录制域、直播域、启动与路由… | accept |
| 518 | `e380c6cac1814237e3374bb093b3d34293b7d7e9` | 2026-10-04 | chore(playback): log what the room-load catch-all swallows | 直播域 | accept |
| 519 | `fcc57f56ca570de93fc268db9294427d9fb2bbfa` | 2026-10-04 | docs(ledger): Steam start failure — the sweep gate was tighter than its own deadline | 文档 | accept |
| 520 | `eda8b4bde2f5770a75b4fa0ada102a6f86674dbc` | 2026-10-04 | docs(ledger): jdlive two-second stall is the property clobber, on a relay | 文档 | accept |
| 521 | `74d6a15657572d9da40920b29ab5da5b851e19a1` | 2026-10-04 | docs(ledger): baidulive missed the gate by 80ms — and retract the proxy timing | 文档 | accept |
| 522 | `bd42596ad9921ac57ef3085df2e8ed22f4ba2449` | 2026-10-04 | fix(probes): repair the danmaku matrix probe, which no longer compiled | 工具与策略脚本 | accept |
| 523 | `462f9b45c614e56709f867ff5b2e646149763e86` | 2026-10-04 | fix(sixroom): read the chat server list as text — the endpoint lies about its mime | 站点适配器与平台契约、测试、文档 | accept |
| 524 | `5d22d1ea3716eb391269c2e24c3e83c885d63102` | 2026-10-04 | feat(probes): ask whether LOOK's CDN cares about the headers we declare | 工具与策略脚本 | accept |
| 525 | `73aeb5931eede0bbb8db54725ee67e2c316a5d34` | 2026-10-04 | fix(playback): a room's declared headers were dropped for seven sites | 直播域、测试、文档 | accept |
| 526 | `102b84523fbaa6c0c94322b17e54e8a56cf16c3a` | 2026-10-04 | feat(playback): the headphone switch covers the picture instead of killing it | 播放器内核、直播域、测试… | accept |
| 527 | `bbb23e521fcfce95b54c2abed970804563971856` | 2026-10-04 | fix(account): signing out of Douyu now drops the whole session | 账号域、设置与持久化、测试 | accept |
| 528 | `8fad120567dbf56fd8df3e1155d931a011210732` | 2026-10-04 | docs(ledger): cookie surface audit — matches upstream, one hygiene fix | 文档 | accept |
| 529 | `b8f5c58734a46791ea7d7927ece9c6131ca27f15` | 2026-10-04 | feat(account): a single place to sign out of everything | 账号域、设置与持久化、测试… | accept |
| 530 | `15cec5bbf2306585c29919c7721df67b9fb1db69` | 2026-10-04 | feat(playback): audio-only mode stops decoding video in the background | 直播域、测试、资源与翻译 | accept |
| 531 | `559690d48986a71afe84c1e5d0578617f16872df` | 2026-10-04 | feat(playback): a dummy video track shows the room cover, not a solid colour | 播放器内核、直播域、测试… | accept |
| 532 | `5a212628c876f5c73aa549701300b1c382d3871e` | 2026-10-04 | fix(playback): the compact PiP window honours the picture cover too | 直播域、测试 | accept |
| 533 | `e05675c5c36e2d3e96a693adb4a58dfb2bd66475` | 2026-10-04 | fix(playback): owned inputs handed the opener a source instead of a recipe | 播放器内核、直播域、测试 | accept |
| 534 | `57597ed28e5990663bbcc2c524441744d430538b` | 2026-10-04 | docs(ledger): the owned-input break was two defects stacked, not one | 文档 | accept |
| 535 | `958f72156304af4228c064cbef9e043ea1f3517a` | 2026-10-04 | fix(i18n): a missing key renders as its own name, so make that impossible | 核心通用层、测试、资源与翻译 | accept |
| 536 | `784b00da3ff4693d5f06b3843b5127317d7e8e99` | 2026-10-04 | fix(playback): an expired signed URL is replaced instead of retried | 直播域、测试、文档 | accept |
| 537 | `59224e02fcdf88ce5af63a3631c9bf068bb9a469` | 2026-10-04 | docs(ledger): why the source refresh carries no timeout of its own | 文档 | accept |
| 538 | `19ec184f059aa86e9bb53022e03202ed40589d95` | 2026-10-05 | chore: update releases.json [skip ci] | 资源与翻译 | accept |
| 539 | `01fd4fec56f13722eaee8171cd8418151210fe41` | 2026-10-06 | fix(player): 克拉克拉语音直播显示房间封面背景 —— 与猫耳FM一致 | 播放器内核、直播域 | accept |
| 540 | `6974e810593ab1b2cc709a7ed351efe887b281a9` | 2026-10-06 | fix(errors): a site that never answered is not a room that can't be read | 站点适配器与平台契约、直播域、核心通用层… | accept |
| 541 | `27334f41284251506a81ca3c95c4cce01cfb60fa` | 2026-10-06 | fix(showroom): API 请求直连绕过应用代理 —— 修复 HandshakeException | 站点适配器与平台契约 | accept |
| 542 | `7dc74dd1465b42b39ae067dd01fb706bb2382c29` | 2026-10-06 | docs(ledger): chzzk's silent child stall, and the one relay that keeps two routes | 文档 | accept |
| 543 | `d11efadba8dfc7d162d8e38af8141c2f49420013` | 2026-10-06 | fix(i18n): a proxied handshake can also be the proxy re-signing TLS | 资源与翻译、文档 | accept |
| 544 | `ce44ab6c75a35142ddc101739438247ad27fc0f4` | 2026-10-06 | fix(fc2live): API 请求直连绕过应用代理 —— 修复 FC2 Live transport 错误 | 站点适配器与平台契约 | accept |
| 545 | `e2fe28aaba4e046196641366541e31f63acaf3d3` | 2026-10-06 | fix(network): 代理开启时信任代理证书 —— 替代按站点绕过代理 | 站点适配器与平台契约、核心通用层 | accept |
| 546 | `2765c5cb1b325944f54f13310bfec4275afea14f` | 2026-10-06 | test(probes): walk the bigo room path and keep every wire answer | 工具与策略脚本 | accept |
| 547 | `21e981da536db32f2a77d8a35642a7f4e4cbeddb` | 2026-10-06 | fix(bigo): a login-walled room says it needs a login, not "try again" | 站点适配器与平台契约、直播域、测试… | accept |
| 548 | `14d9653263785a92bc6221567a9053f7e7e175e6` | 2026-10-06 | fix(fc2): FFmpeg 中继携带 l_ortkn 会话 Cookie —— 修复分片 403 | 站点适配器与平台契约、录制域 | accept |
| 549 | `960bcf7e375f374b8fa9fdb6e193c9aa7e25c44c` | 2026-10-06 | fix(weibo): 房间声明媒体播放请求头 —— 修复建连后无数据 | 站点适配器与平台契约 | accept |
| 550 | `91e2c75b300dcc20d9478d6d4c0ba9bb116d36ad` | 2026-10-06 | fix(bigo): 公开房间 passRoom=null 与 http 头像不再炸 schema —— 详情可读 | 站点适配器与平台契约、工具与策略脚本 | accept |
| 551 | `321f184a9105a801bbfb30667392001de74c24d0` | 2026-10-06 | fix(steam): 广播 CDN 按请求 IP 亲和,代理出口分片 410 —— 播放与上游中继强制直连 | 播放器内核、启动与路由、测试 | accept |
| 552 | `6c29c704744f6b2802e7350fbbd2c3548e6a1c64` | 2026-10-06 | fix(steam): mpv 网络栈读该 CDN 确定性挂死 —— 线路走回环清单中继,中继上游按主机直连 | 站点适配器与平台契约、直播域 | accept |
| 553 | `3a960050bd8d1366ef1c164a48df7e0ba5d2d0a9` | 2026-10-06 | feat(bigo): 账号 Cookie 设置 —— 平台收紧匿名媒体后走登录态 | 站点适配器与平台契约、账号域、启动与路由… | accept |
| 554 | `2e84d68d3c6b038784ad90acd5e850746f14cba6` | 2026-10-06 | fix(bigo): 请求指纹升级为完整浏览器头 —— WAF 按客户端指纹发降级答案 | 站点适配器与平台契约 | accept |
| 555 | `7bb5afc702e2c9be060942e0ee97abe17aa15f32` | 2026-10-06 | fix(dependencies): 更新 flame_barrage 依赖至 0.0.9，改为使用托管源 | 依赖与供应链 | accept |
| 556 | `6229284a865861a552678d67aebc61a8bb8f17fa` | 2026-10-06 | fix(xhs): 分享文案里抽出链接 + 认 /o/ 前缀短链 —— 整段粘贴可开直播间 | 站点适配器与平台契约、测试 | accept |
| 557 | `af884cbf9355901bc89bf58fd481924898e5b2bc` | 2026-10-06 | chore(lib): remove the Chinese comments and keep only what code cannot say | 站点适配器与平台契约、播放器内核、录制域… | adapt |
| 558 | `2367e706769b617da5ff5e7fbce1bb7d4e574e82` | 2026-10-06 | fix(manifest): 移除 AndroidManifest.xml 中的无用注释以简化代码 | Android 原生 | accept |
| 559 | `07aa2a245bf879e7dbb5f2b29cea009d2d0bf51b` | 2026-10-06 | fix(pip): 移动画中画不显示 UI 控件、不裁圆角 | 直播域 | accept |
| 560 | `cb6d72901da0bea32d88fbe81875610a32617272` | 2026-10-06 | fix(pip): 移动端画中画窗口拖不动、四周黑边 | 直播域 | accept |
| 561 | `f59fe91427693a576b1297fe24f3efbe683b5315` | 2026-10-06 | fix(recorder): drive input relay engagement from declared LiveStreamFacts | 录制域、核心通用层、测试 | accept |
| 562 | `0b23c32fa71542ddb82abab717b7ef9b89a082b1` | 2026-10-06 | feat(recorder): local video player and private-directory warning | 录制域、启动与路由、核心通用层… | accept |
| 563 | `6024997908b88aae8c5408337181488d5589cb4a` | 2026-10-06 | fix: 移除多余的注释并更新代理设置，添加 FloatWindowGeometry 测试用例 | 站点适配器与平台契约、播放器内核、录制域… | accept |
| 564 | `3adf25585f1e092e14ea4eb9a2906fb1b2449e2c` | 2026-10-06 | fix(recorder): 私有目录提示只在点录制时出现,更改按钮跳录制设置页 | 录制域 | accept |
| 565 | `81ba871587b4ac1973f9b35688878ce321c7e736` | 2026-10-06 | fix(recorder): 私有目录弹窗改用原生 Navigator.pop —— Get.back 误弹直播间 | 录制域 | accept |
| 566 | `14a49c3711837a7512470cbee4c434e6425f404f` | 2026-10-06 | feat(player): wire kernel floating presenter for the local player | 播放器内核、录制域、测试 | accept |
| 567 | `015ff3b4ef0fe0dd6d5feefaf2aa1a3391e40ba7` | 2026-10-06 | fix(recorder): 私有目录提示只在点录制时出现,更改按钮跳录制设置页 | 录制域、测试 | accept |
| 568 | `6fabc7d0d671e8b8c394e34336bab863ac650683` | 2026-10-06 | ﻿feat(floating): 小窗弹幕修复 + 四周自由缩放、横竖屏分别记忆位置与尺寸 | 播放器内核、直播域、启动与路由… | accept |
| 569 | `b19a68642a508ec24b8d2b6589f108934debce57` | 2026-10-06 | ﻿fix(floating): 小窗弹幕改为 facade 持有的弹幕池；左右缩放不再被半屏宽度上限卡住 | 播放器内核、直播域 | accept |
| 570 | `e1b5055bd004e0c525c5677f009e0de067d4017a` | 2026-10-06 | ﻿fix(floating): 小窗弹幕改由 facade 直接喂自己的池，不再依赖房间控制器；去掉把手上的可见装饰 | 直播域 | accept |
| 571 | `0b26d0d8f6b6efc879195e03c2e002ab977439e4` | 2026-10-06 | ﻿fix(floating): 小窗弹幕补投递队列 + 临时诊断读数 | 播放器内核、直播域 | accept |
| 572 | `a25facd943564f75b8517f22ef5d565a3c10e69c` | 2026-10-06 | ﻿feat(floating): 小窗按直播流方向（竖屏/横屏）分别记忆尺寸与位置，并兼容竖屏直播 | 播放器内核、直播域、设置与持久化… | accept |
| 573 | `42829bb434f42ce2e7b8b1a7f7cbac6952c00db0` | 2026-10-06 | ﻿fix(floating): 小窗弹幕会话不再被作废（真正的根因） | 直播域 | accept |
| 574 | `2cfbf8d3eaae43a76c804228f4bde8f12005f1d8` | 2026-10-06 | ﻿chore(floating): 移除小窗的临时诊断读数与计数 | 播放器内核、直播域 | accept |
| 575 | `f1d795302ba78429bbc01ca6e2940748e7b4899c` | 2026-10-06 | ﻿fix(i18n): 打开直播间时的提示不再说"远端聊天尚待接入" | 资源与翻译 | accept |
| 576 | `00eeb72fe7160232b1ae5087a1de6b16182f5808` | 2026-10-06 | feat(playback): 添加播放开始时间和相关元数据支持 feat(drawables): 添加媒体控制图标（播放、暂停、停止、快进、快退、上一曲、下一曲） | 播放器内核、直播域、Android 原生 | accept |
| 577 | `db351a6d60ddecff369db0ca7a73cefd0c2b722c` | 2026-10-06 | ﻿fix(notification): 播放直播时状态栏通知显示房间名，而不是流地址文件名 | 直播域 | accept |
| 578 | `b62805959ad78e94c7e3391899f1a0edb3549353` | 2026-10-06 | fix(player): force-seekable no for live streams without a declared start | 播放器内核、测试 | accept |
| 579 | `ced13040bbab017b8e854b72835544626d356ad6` | 2026-10-06 | Revert "fix(player): force-seekable no for live streams without a declared start" | 播放器内核、测试 | accept |
| 580 | `796823afd53e22b5fd7b14643c19eaf9bd2bd6f6` | 2026-10-06 | ﻿feat(recorder): 重做录像播放页 UI，并让录像能交给小窗播放 | 播放器内核、录制域、启动与路由… | accept |
| 581 | `555c0bbd39d2ec31cdc03667b7ec4efa67b74dcd` | 2026-10-06 | refactor(player): 抽出共用播放器层，录像页改用直播那套控制与手势 | 播放器内核、录制域、直播域… | accept |
| 582 | `8570b1bb1190d461fe09d9bf9b708d7ef534b4b6` | 2026-10-06 | docs(ledger): 记录共用播放器层抽取与录像页改造 | 文档 | accept |
| 583 | `8e0da21510dd319a2c0476c5511a621ee487826a` | 2026-10-06 | fix(recorder): RxList 默认初始值是 const []，录屏列表改成长度可变的 | 录制域 | accept |
| 584 | `d8dc94af59274fa888ee0a062070aa2de4635c24` | 2026-10-07 | feat(recorder): 录像播放页改短视频式布局 —— 上下文面板+全屏胶囊+选集抽屉,弹幕/PiP/小窗沿用共用层 | 录制域、资源与翻译 | accept |
| 585 | `61b88e04c87e4b3a2eec420cc9ce4e27afb37304` | 2026-10-07 | feat(recorder): 录像播放页顶部栏改倍速+三点,bottomsheet 设置与选集分离 —— 对齐参考业务 | 录制域、资源与翻译 | accept |
| 586 | `2b751a7e094255f4a456791c9ae00bd799ec4c89` | 2026-10-07 | style(recorder): 面板恢复快捷按钮行,选集条改悬浮样式,设置抽屉分组卡片化 | 录制域 | accept |
| 587 | `994fa563f353b234c3839609a0dcff59b7816a60` | 2026-10-07 | fix(recorder): 关掉库顶栏消除双层标题,页面顶栏补状态栏安全区 | 录制域 | accept |
| 588 | `9a0a08d372840109b7a70246a2badd61808ada50` | 2026-10-07 | fix(player): 亮度HUD默认隐藏,录像页小加载态+选集图标,直播全屏栏让出刘海与手势区 | 播放器内核、录制域、直播域 | accept |
| 589 | `5763928faf3ee00bbb4a2337243329ac1fa252b3` | 2026-10-07 | fix(recorder): 吞掉内核操作被取代的取消异常 —— 音量手势/拖进度不再冒未处理异常 | 录制域 | accept |
| 590 | `c63bdb371c652fafd24804e82af1aa46a660979c` | 2026-10-07 | feat(recorder): 小窗与画中画对齐直播样式 —— 全边缩放/记忆位置/控件层,桌面PiP复刻overlay | 播放器内核、录制域 | accept |
| 591 | `81f9e23dcddf11ec0bc5d4fc43e70ae1650f06e6` | 2026-10-07 | fix(recorder): 面板标题去掉无观察对象的 Obx —— ObxError 连带撑爆 Column | 录制域 | accept |
| 592 | `4e4e478ca0b8272bcfc19af97b2435e5b990f99e` | 2026-10-07 | chore: update releases.json [skip ci] | 资源与翻译 | accept |
| 593 | `3fba7b878f9f7accfe360c8b17a43c42c6956829` | 2026-10-07 | fix(recorder): 控制条跟随主题色,全屏走直播式横屏,PiP整页替换,小窗位置记忆并入直播配置 | 播放器内核、录制域 | accept |
| 594 | `f1dd6cfb4ff110617c7decff2d6f24f9a06a9997` | 2026-10-07 | fix(recorder): 进入录像播放先暂停直播间 —— 消除后台声音与画面残留 | 录制域 | accept |
| 595 | `c9d2a41a81c83475ab8c639af020962e9ac5e353` | 2026-10-07 | feat(recorder): 适应宽度/PiP/小窗移到底部控件行,全屏改一键切换且只渲染视频区,关库英文溢出菜单 | 录制域 | accept |
| 596 | `322e28669aca333a3e9a7f396103250ab3a31324` | 2026-10-07 | fix(recorder): 底栏去掉重复的画中画/小窗,AppBar 去掉重复的打开目录 | 录制域 | accept |
| 597 | `ce5c026b11c0a460e73fd4f531862be83d889bfb` | 2026-10-07 | feat(recorder): 底栏加±10s跳转,返回键跟随floatPlay设置转小窗,打开即播 | 录制域 | accept |
| 598 | `57ae47320d1d692703a80db2b41705095f218855` | 2026-10-07 | fix(recorder): 桌面画中画整页替换 —— AppBar 等页面 chrome 不留在缩小的窗口里 | 录制域 | accept |
| 599 | `9fed7d9734474820d2eb6ef50ef354c9103eb4ac` | 2026-10-07 | fix(player): 超分挂载不再交逗号串 —— 整串被 mpv 当成一个 shader 路径, 直播全线判播放失败 | 播放器内核、测试 | accept |
| 600 | `80d4fed2936c2ec08f0794191e2b63f93fafb80b` | 2026-10-07 | test(player): 列表选项钉成逐条 append —— 上一版逗号串写法被运行日志证伪 | 测试 | accept |
| 601 | `12e246c3971d09aa558fcd1c5257b80be89801e4` | 2026-10-07 | fix(player): 录像的小窗/画中画对齐直播间 —— 角标、时长、压在画面上的标题栏 | 播放器内核、核心通用层、测试… | accept |
| 602 | `982f3721b638e68d9abaedf18a008eea6b1665b0` | 2026-10-07 | fix(recorder): 小窗点"回到页面"接着播 —— 展开前先把当前位置落盘 | 录制域 | accept |
| 603 | `5c18b0fae0895ebe9090e53bb52b523337391848` | 2026-10-07 | feat(recorder): 录像播放页兼容小屏 —— 窄窗口改成画面在上、列表在下 | 录制域、测试 | accept |
| 604 | `14810ff277c21e184769b7591cad459e36ba1ec2` | 2026-10-07 | feat(player): 紧凑窗口用可拖进度条 —— 小窗里也要能改播放位置 | 播放器内核、测试 | accept |
| 605 | `0bdad884cf5358eecac2bf107a051213a2e9d6d9` | 2026-10-07 | fix(recorder): 全屏里的画中画与退出恢复 —— 状态跟驱动，紧凑窗口加进度条 | 录制域 | accept |
| 606 | `cc2af0daf53dcd654de288677a2280992a4c07f3` | 2026-10-07 | feat(player): 小窗控制层无操作 5 秒后收起 | 播放器内核 | accept |
| 607 | `af8929839a01b820635025eaa09a2a6ac3dfe6b8` | 2026-10-07 | fix(player): 紧凑进度条自带 Material —— 小窗那层裸 Overlay 里 Slider 直接抛异常 | 播放器内核、测试 | accept |
| 608 | `7161050a68987b7c995479347efae7d2fa7a5be9` | 2026-10-07 | fix(recorder): 录像画中画自带黑底 —— 透明 Scaffold 把浅色主题透成白边 | 录制域 | accept |
| 609 | `4a621afd90a6f21283868a1fa5162c72b4fdf313` | 2026-10-07 | fix(recorder): 短片不再被当成"已看完" —— 展开小窗后接着播，而不是从头 | 录制域、测试 | accept |
| 610 | `7ef95314e9474601eee7e3956a4eb651091e021b` | 2026-10-07 | feat: add danmaku settings page and related functionality | 播放器内核、录制域、直播域… | accept |
| 611 | `83e5673b3bfefc5e1b6ec2c26cd29aa500e3762e` | 2026-10-07 | feat(recorder): 仅音频 / 截图 / 画中画移到画面右上角常驻 | 录制域、资源与翻译 | accept |
| 612 | `4b8e60b6300e91ec2d19fb69bb3fc5eb9448684f` | 2026-10-07 | fix(recorder): 关掉小窗也落一次进度 —— 在小窗里看的那段不再丢 | 录制域 | accept |
| 613 | `a858550bb8753f47bc279a4e45f5cb2707cf5937` | 2026-10-07 | sync(huya,douyu): 对齐 simple_live —— UA 升至 7100004/2.40.0,斗鱼 ws 线 expire=0 补丁;修测试导入分号 | 站点适配器与平台契约 | accept |
| 614 | `5bcd5f3c20753f069b71dc4f52fcff7ab373d605` | 2026-10-07 | fix(recorder): 小屏不再显示音量滑条 —— 那 100px 就是控制行溢出 50 像素的原因 | 录制域 | accept |
| 615 | `2eba60f4b73c5bab153d824b46abc4fc4875b120` | 2026-10-07 | fix(player): 紧凑窗口的横竖屏按"里面这个播放器"判断 —— 录像不再借用直播的方向 | 播放器内核 | accept |
| 616 | `98f20b5339970e3630273b034e1e1bcb46a82a76` | 2026-10-07 | fix(player): 远端渐进式流禁 cache-pause —— 直播先播两秒停缓冲再续播的根因 | 播放器内核、测试 | accept |
| 617 | `6a3ab101654c8c05e3fd187a68cf32c4ca241c13` | 2026-10-07 | fix(video_controller): 优化全屏状态下的按钮显示逻辑 —— 修复小窗口模式下的全屏按钮显示问题 | 直播域 | accept |
| 618 | `a182c0b29703bf55071d321cb5f7d7c6c63b5c36` | 2026-10-07 | fix(recorder): 播放器快捷键挂到页面自己的 Focus —— 重建后空格/Esc/f 失效的根因 | 录制域 | accept |
| 619 | `16bf5ea121de2cd455f4da4c5fc6c3f3a81768ea` | 2026-10-07 | fix(recorder): 全屏的返回语义与横竖屏形状，对齐直播间 | 录制域、资源与翻译 | accept |
| 620 | `cf50b0157c1b96b4e3e73eba265c6b3c9eb54bf1` | 2026-10-07 | feat(recorder): 窄窗口的右上角入口收进设置面板，并去掉面板里的小窗播放 | 录制域 | accept |
| 621 | `12121396628c568ca328c1cb73a6662c42272f11` | 2026-10-07 | refactor(recorder): 播放页去掉中文注释，硬编码文案改走 i18n | 录制域、资源与翻译 | accept |
| 622 | `d3ad68be12d43cca6e0b73bef4c29db502ca342c` | 2026-10-07 | fix(recorder): 复查三处 —— Esc 只退出全屏、桌面加载态不再吞掉画面、去掉重复 PiP 分支 | 录制域 | accept |
| 623 | `62af8d80e7335a8f1b343f590b68c65506010f52` | 2026-10-07 | fix(recorder): 快捷键搬到页面层 —— 进全屏后空格/Esc/F 不再失灵 | 录制域 | accept |
| 624 | `523f84921073cacd32ec11c15f3f02f402373c51` | 2026-10-07 | fix(live): 房间快捷键的焦点自己持有 —— 全屏/画中画切换后 Space/Esc 不再失联 | 直播域 | accept |
| 625 | `c7cf5463efbf5dc60446b3810c55b9f3ce9f175c` | 2026-10-07 | feat(live): 房间键位收成一张可测的表，并补上 F 全屏切换 | 直播域、测试 | accept |
| 626 | `a4ee80b29b95cf299ac612c80a0209159d6c48b8` | 2026-10-07 | feat(live): 房间补上 M 静音键 —— 静音是切换，不是归零 | 直播域、测试 | accept |
| 627 | `e40bd2822020034147945006a9a2327e7be80650` | 2026-10-07 | refactor(i18n): 播放预设的名称与说明搬进语言包 | 播放器内核、独立功能页、资源与翻译 | accept |
| 628 | `0f2cda489f0f9c8786145e6345adcb24cb9f89ee` | 2026-10-07 | feat(settings): 播放内核补上一键配置入口，Android 另有硬解兼容修复 | 独立功能页、资源与翻译 | accept |
| 629 | `0e132cd3efd979522383afd6d19c0419c91088f8` | 2026-10-07 | refactor(i18n): 加载动画名称搬进语言包 —— 85 组 nameZh/nameEn 列删除 | 独立功能页、核心通用层、设置与持久化… | accept |
| 630 | `e93587103821f81f37e7b58fe687c3395e17d580` | 2026-10-07 | refactor(i18n): mpv option and super-resolution names move to the locale bundles | 播放器内核、独立功能页、测试… | accept |
| 631 | `b88105db01924b7fc72838659c62c50725811d55` | 2026-10-07 | refactor(i18n): wallpaper library source and group names move to the locale bundles | 壁纸域、测试、资源与翻译 | accept |
| 632 | `db54cb271c11580b53cee3ede9352142aba718a7` | 2026-10-07 | refactor(i18n): random wallpaper API names move to the locale bundles | 壁纸域、测试、资源与翻译 | accept |
| 633 | `8cf4376915ef2caab09bad9736239eca115ab8bc` | 2026-10-07 | fix(player): 手势层不再吞掉点击 —— 直播间点视频区域重新能弹出控制栏 | 播放器内核、直播域 | accept |
| 634 | `3b13546b70e00c1f0a4fe88ef6e4b027524d87c2` | 2026-10-07 | refactor(i18n): player manual wording moves to the locale bundles | 独立功能页、测试、资源与翻译 | accept |
| 635 | `abd9eab61ac90aa0e88441a5770adefd66e51683` | 2026-10-07 | fix(recorder): 移动端全屏形状跟状态走、返回先退全屏、右上角按钮真正出现 | 录制域 | accept |
| 636 | `24dc2bc2b2c836d12bc0f3bf38f762ca8eb8987e` | 2026-10-07 | refactor(i18n): live quality names resolve through the locale at the display seam | 播放器内核、录制域、核心通用层… | accept |
| 637 | `33499909b1aab83e7dcc39ae1651586ca842cff4` | 2026-10-07 | fix(player): 返回键改走 PlayerBackScope —— 安卓返回终于能先退全屏 | 播放器内核、录制域 | accept |
| 638 | `c703309334647a0cc1b9f4d44ee5113d2f7db85a` | 2026-10-07 | fix(i18n): the live compact window's play and exit labels follow the language | 播放器内核、资源与翻译 | accept |
| 639 | `83e06baf7c1d63adad302fffec95c5c27feba1b3` | 2026-10-07 | refactor(i18n): last hardcoded interface strings found by the CJK sweep | 直播域、账号域、资源与翻译 | accept |
| 640 | `7c97e6237b94a28c3e28cc8ae4d8933cee94bec2` | 2026-10-07 | fix: 添加 PureLiveScrollPhysics 到多个 ListView 以改善滚动体验 | 录制域、直播域、账号域… | accept |
| 641 | `aecc62c102c3a69e5d22c09f3887a632fb759e85` | 2026-10-07 | fix(player): 竖屏刘海适配 —— 顶底控制栏让出安全区，不再被状态栏和手势条压住 | 录制域、直播域 | accept |
| 642 | `32b6c7ecffec60d468dab5116f5b3b93e60aa7c6` | 2026-10-07 | fix(recorder): 返回键真的接上了 —— PlayerBackScope 的 presentationActive 之前恒为 false | 播放器内核、录制域 | accept |
| 643 | `554d14e9adeaa840fedb2eabc143edb651eb156e` | 2026-10-07 | fix(recorder): ship the sheet body widget the overflow fix calls | 核心通用层、测试 | accept |
| 644 | `bb3c2c50718ca7429af249da8f8321557269c229` | 2026-10-07 | fix(player): 全屏刘海适配 —— 系统隐藏状态栏后自己报 0，改用真实挖孔安全区 | 录制域、直播域、启动与路由… | accept |
| 645 | `79029cfb7d4283e9504620b49a8273cae8f6ee17` | 2026-10-07 | fix(recorder): 画中画窗口不再被裁圆角、也不再留一圈底色 | 录制域 | accept |
| 646 | `45289b01fc12403917691f98b46333fc74cb5a21` | 2026-10-07 | refactor(player): 删掉自建刘海适配，改用 SafeArea | 录制域、直播域、启动与路由… | accept |
| 647 | `9ffb4f133f7667cdd342bec273b846728e2ab005` | 2026-10-08 | fix(player): 控制栏按 viewPadding 自己让位 —— 视频铺满，只有按钮避开猫耳朵 | 录制域、直播域 | accept |
| 648 | `05610aded6a941cce5ecf27afb6bfb6ffdda0581` | 2026-10-08 | fix(manifest): 添加 windowLayoutInDisplayCutoutMode 属性以支持刘海屏适配 | Android 原生 | accept |
| 649 | `60f2a69dbabb1e9f76f53eeccad94533030f82de` | 2026-10-08 | fix(live): 竖屏全屏的顶栏避开刘海 —— 沉浸态系统报 0 时用状态栏高度兜底 | 直播域 | accept |
| 650 | `8cf062eda796bb331d6ffdf679949a0092f86825` | 2026-10-08 | fix: 更新导航返回逻辑，使用 Navigator.pop() 替代 Get.back()，确保更好的兼容性 | 录制域、账号域、独立功能页 | accept |
| 651 | `87c17c94369fbe4fd0a7592a04c379ab3f79da54` | 2026-10-08 | fix(recorder): 返回键只做两段语义 —— 全屏先退全屏，非全屏退出页面 | 录制域 | accept |
| 652 | `d0247eebe5faad3c3fb30dd5269af3bdb39c1bd6` | 2026-10-08 | fix(core): 返回回调不再被自己人清掉 —— 按路由登记/解除，而不是清空全局字段 | 播放器内核 | accept |
| 653 | `a3b7e56e1ecf3b6d2020cfb63eab741fcc103ace` | 2026-10-08 | fix(recorder): 全屏时让 canPop 为 false —— 由 Flutter 自己保证"再按一次才退页面" | 录制域 | accept |
| 654 | `23d0f23586edecad8e2fc55403fde9be177d3ac1` | 2026-10-08 | revert(core): 还原 android_predictive_back_service.dart —— live_play 与多画面都在用它 | 播放器内核 | accept |
| 655 | `d133a943b9d126388c50de214bb4ac102cab4837` | 2026-10-08 | fix(player): 录像页自己离开路由 + 多画面挂上 PlayerBackScope | 播放器内核、录制域、直播域 | accept |
| 656 | `94b154f92e284c492da7a30130a1e6ae58fab2b7` | 2026-10-08 | fix(recorder): 桌面全屏底部不再挂片单 —— 与手机全屏一致，只剩画面 | 录制域 | accept |
| 657 | `8434bc1c0b1cc473c6e3db45f064d280ded4a8eb` | 2026-10-08 | fix(local_video_player): 修复桌面全屏时按钮消失的问题 —— 确保在全屏模式下仍然显示必要的控制按钮 | 录制域 | accept |
| 658 | `80141d545533b9b4c65ab4ae6344bb6775889869` | 2026-10-08 | build(deps,ci): media_core 改 git 依赖；补上 Linux 打包真正缺的两件事 | 依赖与供应链、工作流、工具与策略脚本 | adapt |
| 659 | `bdce5600ab795d26f2de937536a5307175e341cb` | 2026-10-08 | chore(version): 更新版本号至 3.1.18.4107 | 资源与翻译、Windows 原生 | accept |
| 660 | `2a4451908713472ea566b4bf9dda5eda963169d6` | 2026-10-08 | chore(workflow): 删除分层架构校验工作流文件 | 工作流 | accept |
| 661 | `fab5cd495eddd7472bb016518af1009df2c9292b` | 2026-10-08 | fix(ci): Flutter SDK 版本校验读不到 version 文件 —— 3.47 的归档已改布局 | 工作流 | adapt |
| 662 | `4a0cf09fe4c4f51b71a86a3fae619f04a2c0571d` | 2026-10-08 | Remove outdated GitHub workflows for signing Android APKs and staging hosted artifacts; update dependencies in pubspec.lock to latest versions. | 依赖与供应链、工作流 | accept |
| 663 | `51baab5ffc96c83df915ef0b7334052be85585f2` | 2026-10-08 | build(linux): 参考 dart_simple_live 同步 Linux 打包，版本页提供 Linux 多格式下载 | 独立功能页、发布与更新、工作流… | adapt |
| 664 | `141b4f9b6db8d61d04d0625f6ac7ef036ea3fb06` | 2026-10-08 | ci(release): 全平台默认并行打包 | 工作流 | adapt |
| 665 | `6a92a4dc0ba5b498d0d9c401932c968c90a5600d` | 2026-10-08 | ci(release): Flutter SDK 改用最新 stable，不再在仓库内固定版本与哈希 | 工作流 | adapt |
| 666 | `73aba047be0139af1d2577003d148b1f12e7dd07` | 2026-10-08 | 更新 version.json | 资源与翻译 | accept |
| 667 | `4bf28f0b6bff2e89f318e400fda014b86b1d8121` | 2026-10-08 | ci(release): 移除 FFmpeg native bundle 校验链路，精简发布 workflow | 工作流 | adapt |
| 668 | `15681af0f8ea99dd351a28dcdfa339be758801fb` | 2026-10-08 | ci(release): 更新版本号至 3.1.18，添加 AppLinks 插件支持 | 依赖与供应链、资源与翻译、Linux 原生 | accept |
| 669 | `366164108a9890fef09b22e3d040051ae17183e1` | 2026-10-08 | ci(release): fastforge 0.6.0 → 0.6.12 | 工作流、Linux 原生 | adapt |
| 670 | `b6eb49f336f91fab2599b71c3dd93a9dfc7e73a6` | 2026-10-08 | fix(ci): Android 构建关闭 Gradle configuration cache(仅 CI) | 工作流 | adapt |
| 671 | `85c8402d34a5658a4487d1b1fe12291956531332` | 2026-10-08 | chore: 注释掉代理设置以避免构建问题 | Android 原生 | accept |
| 672 | `e3bb4142fca5ac17b292891f5b6cd235b53a52ce` | 2026-10-08 | chore: update releases.json for v3.1.18 [skip ci] | 资源与翻译 | accept |
| 673 | `322c6547a2ea1b7c26e4f9090b8161f658d8906e` | 2026-10-08 | chore: update releases.json [skip ci] | 资源与翻译 | accept |
| 674 | `467977e3f0714c4070e8d6ceaf68d35158101333` | 2026-10-08 | fix(player,sync): macOS 进直播间闪退、开屏炸音与设备同步直达选择页 | 播放器内核、直播域、独立功能页 | accept |
| 675 | `2d13690958a41a4b750ed8954ac299db3b15dfe1` | 2026-10-08 | chore: update releases.json for v3.1.18 [skip ci] | 资源与翻译 | accept |
| 676 | `14a44907e78504e81887e98a193964878bc5110a` | 2026-10-09 | chore: update releases.json [skip ci] | 资源与翻译 | accept |
| 677 | `e7a794c00736322513ad249c8202fefcc7f323ed` | 2026-10-09 | fix(pagination): 每页数量选择持久化,不再每次进入回退默认 20 | 直播域、核心通用层 | accept |
| 678 | `1256828ce703543e0edbcebe602ead65ebf2a55a` | 2026-10-09 | fix(player): iOS 退出全屏后恢复竖屏 | 播放器内核 | accept |
| 679 | `30935111122c08dcbd315eaaabe4c4d5bcbad046` | 2026-10-09 | fix(player): 手机端直播间音量滑杆不再被隐藏的播放器增益砍半 | 直播域 | accept |
| 680 | `e3d45d3cd8eefee433666c43b5a6a14c2fd215a8` | 2026-10-09 | fix(window): 添加全屏状态下的窗口控制按钮以支持最小化和关闭功能 | 核心通用层 | accept |
| 681 | `4d4363d78a884349b0c12a59739fdf4185273963` | 2026-10-09 | fix(danmaku): 关闭画面弹幕不再连坐侧边栏与全局开关 | 直播域 | accept |
| 682 | `6295de272f6c43854c5021e3fd226d3ea25a28e5` | 2026-10-09 | sync(huya): 对齐 dart_simple_live —— gid 四态兼容 + 端点实测探针 | 站点适配器与平台契约、工具与策略脚本 | accept |
| 683 | `ff98cd046d7ddba8c8af1f6c234c96f719b4807b` | 2026-10-09 | sync(huya): 对齐 dart_simple_live-dev —— isVip/4K、随机 UA、SC 触发与排序 | 站点适配器与平台契约 | accept |
| 684 | `8f9874e9480673c8ea91703e7f800e4cacd826d7` | 2026-10-09 | fix(player): 系统返回不再被拦截为系统画中画 —— 统一为返回上级界面 | 直播域 | accept |
| 685 | `b982dca02347b6c4b38549a260866c39d8ab5da9` | 2026-10-09 | fix(platforms): 外部打开链接把房间号换回 liveroom.roomId —— 11 个站点恢复 | 站点适配器与平台契约 | accept |
| 686 | `3f1a464e9809ca7cf74819909ba10a56b84c956f` | 2026-10-09 | fix huya 画质 | 站点适配器与平台契约 | accept |
| 687 | `85e2154cd6bad10494e260bc246b79ef6e3ef2cd` | 2026-10-09 | add new version | 站点适配器与平台契约、直播域、依赖与供应链… | accept |
| 688 | `31d4d96b59f87209e2364397296940c7f04a1d9f` | 2026-10-10 | Update version.json | 资源与翻译 | accept |
| 689 | `f4189f5627a2786b90b536bb512ebad279cc3fb4` | 2026-10-10 | chore: update releases.json for v3.1.19 [skip ci] | 资源与翻译 | accept |
| 690 | `96890815f932996871a569f785c1be1ba0ec02bc` | 2026-10-10 | chore: update releases.json [skip ci] | 资源与翻译 | accept |
| 691 | `e946e0d29029a767ce81ad703d84acb648d63989` | 2026-10-11 | chore: update releases.json [skip ci] | 资源与翻译 | accept |
| 692 | `06ffd8651bf8563c1320991b08b8d966a0bbc9e5` | 2026-10-11 | chore: update media_core dependencies to latest commit ref | 依赖与供应链 | accept |
| 693 | `ec0a1bc13c0df4a5ebbac01202ba820340429acb` | 2026-10-12 | fix(ios): add UIBackgroundModes audio for background playback | Apple 原生 | accept |
| 694 | `2530e04cf6e87f18ff2e2ac541b3637c1cd686cf` | 2026-10-12 | Merge pull request #931 from vancez/master | — | accept |
| 695 | `74d2b88ef764032434c8c17b6ac5e9e89cba8456` | 2026-10-13 | chore: update releases.json [skip ci] | 资源与翻译 | accept |
| 696 | `782f113d5ce1cf8555d5052226e5a316f94adda6` | 2026-10-15 | chore: update releases.json [skip ci] | 资源与翻译 | accept |
| 697 | `5ed3ed48e145f9ba844d576a220d2e80a44c7bca` | 2026-10-17 | chore: update releases.json [skip ci] | 资源与翻译 | accept |
| 698 | `997713d21498350a92f260951fb0400f51e8ef42` | 2026-10-19 | chore: update releases.json [skip ci] | 资源与翻译 | accept |
| 699 | `6b9f6c3180e201abb9c8a4bbbd6e6bd5c703fbc4` | 2026-10-21 | chore: update releases.json [skip ci] | 资源与翻译 | accept |
| 700 | `e1fe2b90ef66e119cc0aa930d166076fadf86b54` | 2026-10-23 | chore: update releases.json [skip ci] | 资源与翻译 | accept |
| 701 | `b6d57759933029e3086990fcf466088ec256b939` | 2026-10-25 | chore: update releases.json [skip ci] | 资源与翻译 | accept |
| 702 | `0fa4d23dcde0b245f7abf6fae26333716d756aa3` | 2026-10-27 | chore: update releases.json [skip ci] | 资源与翻译 | accept |
| 703 | `0c7d246fc91d578e228a25319e6a161ba0e24180` | 2026-10-29 | chore: update releases.json [skip ci] | 资源与翻译 | accept |
| 704 | `63ce0126888f3d24abed74de683cdc74a41e62b6` | 2026-10-31 | chore: update releases.json [skip ci] | 资源与翻译 | accept |
| 705 | `81bd78c1c1789e0e255e95974055ba057cafc7ce` | 2026-11-01 | chore: update releases.json [skip ci] | 资源与翻译 | accept |
| 706 | `a65731adaecf71c98fcb9b12e023e3c41571f575` | 2026-11-01 | build(ci): keep manual release inputs off and drop imported whitespace errors | 直播域、启动与路由、工作流… | adapt |
| 707 | `0c91098ed45895ab232f616db293a4f8dc63b032` | 2026-11-01 | chore: treat native patch files as whitespace-significant in diff checks | 壁纸域、仓库元数据 | adapt |

## 附录 B：变更文件全量清单（2024 个，`file_review`）

| 状态 | 文件 | category | risk | + | − | 处置 |
| --- | --- | --- | --- | --- | --- | --- |
| M | `.env` | `repository_metadata` | low | 3 | 0 | adapt |
| M | `.env.dev` | `repository_metadata` | low | 3 | 0 | accept |
| M | `.env.prod` | `repository_metadata` | low | 3 | 0 | accept |
| M | `.gitattributes` | `repository_metadata` | low | 1 | 0 | adapt |
| A | `.github/actions/get-version/action.yml` | `repository_metadata` | low | 21 | 0 | accept |
| D | `.github/workflows/audit-upstream.yml` | `workflows_and_release` | high | 0 | 47 | accept |
| D | `.github/workflows/build-ios-unsigned.yml` | `workflows_and_release` | high | 0 | 209 | accept |
| D | `.github/workflows/build-native-ffmpeg-apple.yml` | `workflows_and_release` | high | 0 | 204 | accept |
| M | `.github/workflows/build_pure_live_release.yml` | `workflows_and_release` | high | 123 | 143 | adapt |
| D | `.github/workflows/feature-build.yml` | `workflows_and_release` | high | 0 | 1715 | accept |
| D | `.github/workflows/local-signed-android.yml` | `workflows_and_release` | high | 0 | 150 | accept |
| D | `.github/workflows/publish-signed-android.yml` | `workflows_and_release` | high | 0 | 132 | accept |
| D | `.github/workflows/publish-staged-release.yml` | `workflows_and_release` | high | 0 | 493 | accept |
| D | `.github/workflows/sign-staged-android.yml` | `workflows_and_release` | high | 0 | 304 | accept |
| D | `.github/workflows/stage-hosted-artifacts.yml` | `workflows_and_release` | high | 0 | 163 | accept |
| M | `AGENTS.md` | `tooling_and_policy` | low | 15 | 3 | accept |
| M | `CLAUDE.md` | `repository_metadata` | low | 9 | 0 | accept |
| M | `README.md` | `repository_governance` | medium | 15 | 15 | accept |
| M | `RELEASE_NOTES.md` | `workflows_and_release` | high | 379 | 0 | accept |
| M | `analysis_options.yaml` | `repository_metadata` | low | 6 | 0 | accept |
| M | `android/app/src/main/AndroidManifest.xml` | `android_native` | high | 8 | 4 | accept |
| M | `android/app/src/main/kotlin/com/mystyle/pure_live/MainActivity.kt` | `android_native` | high | 233 | 44 | accept |
| M | `android/app/src/main/kotlin/com/mystyle/pure_live/NativeHttpChannel.kt` | `android_native` | high | 7 | 4 | accept |
| A | `android/app/src/main/res/drawable/ic_media_forward.xml` | `android_native` | high | 10 | 0 | accept |
| A | `android/app/src/main/res/drawable/ic_media_next.xml` | `android_native` | high | 10 | 0 | accept |
| A | `android/app/src/main/res/drawable/ic_media_pause.xml` | `android_native` | high | 10 | 0 | accept |
| A | `android/app/src/main/res/drawable/ic_media_play.xml` | `android_native` | high | 10 | 0 | accept |
| A | `android/app/src/main/res/drawable/ic_media_previous.xml` | `android_native` | high | 10 | 0 | accept |
| A | `android/app/src/main/res/drawable/ic_media_rewind.xml` | `android_native` | high | 10 | 0 | accept |
| A | `android/app/src/main/res/drawable/ic_media_stop.xml` | `android_native` | high | 10 | 0 | accept |
| M | `android/build.gradle.kts` | `android_native` | high | 13 | 9 | accept |
| M | `android/gradle/wrapper/gradle-wrapper.properties` | `android_native` | high | 2 | 2 | accept |
| M | `android/settings.gradle.kts` | `android_native` | high | 1 | 1 | accept |
| A | `assets/fonts/MiSans-Regular.ttf` | `translations_and_assets` | medium | None | None | accept |
| M | `assets/releases.json` | `workflows_and_release` | high | 687 | 295 | accept |
| A | `assets/shaders/Anime4K_AutoDownscalePre_x2.glsl` | `translations_and_assets` | medium | 36 | 0 | accept |
| A | `assets/shaders/Anime4K_AutoDownscalePre_x4.glsl` | `translations_and_assets` | medium | 36 | 0 | accept |
| A | `assets/shaders/Anime4K_Clamp_Highlights.glsl` | `translations_and_assets` | medium | 90 | 0 | accept |
| A | `assets/shaders/Anime4K_Restore_CNN_M.glsl` | `translations_and_assets` | medium | 275 | 0 | accept |
| A | `assets/shaders/Anime4K_Restore_CNN_S.glsl` | `translations_and_assets` | medium | 137 | 0 | accept |
| A | `assets/shaders/Anime4K_Restore_CNN_VL.glsl` | `translations_and_assets` | medium | 873 | 0 | accept |
| A | `assets/shaders/Anime4K_Upscale_CNN_x2_M.glsl` | `translations_and_assets` | medium | 300 | 0 | accept |
| A | `assets/shaders/Anime4K_Upscale_CNN_x2_S.glsl` | `translations_and_assets` | medium | 158 | 0 | accept |
| A | `assets/shaders/Anime4K_Upscale_CNN_x2_VL.glsl` | `translations_and_assets` | medium | 969 | 0 | accept |
| M | `assets/translations/en.json` | `translations_and_assets` | medium | 649 | 78 | accept |
| M | `assets/translations/zh.json` | `translations_and_assets` | medium | 651 | 80 | accept |
| M | `assets/version.json` | `workflows_and_release` | high | 31 | 31 | accept |
| A | `docs/ACCEPTANCE_FLOW.md` | `tooling_and_policy` | low | 27 | 0 | accept |
| M | `docs/ACCEPTANCE_STATUS_3_2_0.md` | `tooling_and_policy` | low | 2 | 2 | accept |
| M | `docs/BUILD_AND_RELEASE.md` | `tooling_and_policy` | low | 28 | 3 | accept |
| M | `docs/DEPENDENCY_AUDIT.md` | `tooling_and_policy` | low | 8 | 2 | accept |
| M | `docs/FEATURE_EXPANSION_3_2_0.md` | `tooling_and_policy` | low | 4 | 16 | accept |
| M | `docs/ISSUE_TRIAGE_LEDGER_3_2_0.md` | `tooling_and_policy` | low | 11 | 0 | accept |
| M | `docs/PLATFORM_COMPATIBILITY.md` | `tooling_and_policy` | low | 7 | 2 | accept |
| M | `docs/PLATFORM_EXPANSION_AUDIT_2026_09_07.md` | `tooling_and_policy` | low | 1 | 1 | accept |
| A | `docs/PLATFORM_PROBE_2026_09_25.md` | `tooling_and_policy` | low | 97 | 0 | accept |
| A | `docs/PLATFORM_SYNC_LEDGER_4X.md` | `tooling_and_policy` | low | 1560 | 0 | accept |
| M | `docs/README.md` | `tooling_and_policy` | low | 3 | 0 | accept |
| A | `docs/TEST_CHECKLIST.md` | `tooling_and_policy` | low | 135 | 0 | accept |
| A | `docs/UPSTREAM_PORT_2026_09_27.md` | `tooling_and_policy` | low | 72 | 0 | accept |
| A | `docs/WALLPAPER_SOURCES_PAGING_PREVIEW_2026_10_03.md` | `tooling_and_policy` | low | 86 | 0 | accept |
| A | `docs/media_core_migration.md` | `tooling_and_policy` | low | 45 | 0 | accept |
| M | `ios/Runner/Info.plist` | `apple_native` | high | 4 | 0 | accept |
| A | `lib/app/bootstrap/desktop_exit_flow.dart` | `other_application_source` | medium | 251 | 0 | accept |
| A | `lib/app/bootstrap/initial_services.dart` | `other_application_source` | medium | 213 | 0 | accept |
| R063 | `lib/app/bootstrap/initialized.dart` | `other_application_source` | medium | None | None | accept |
| R057 | `lib/app/router/app_pages.dart` | `other_application_source` | medium | None | None | accept |
| R060 | `lib/app/router/navigation_observer.dart` | `other_application_source` | medium | None | None | accept |
| A | `lib/app/router/page_bindings.dart` | `other_application_source` | medium | 254 | 0 | accept |
| D | `lib/common/base/index.dart` | `common_runtime` | medium | 0 | 13 | accept |
| D | `lib/common/base/paging_model.dart` | `common_runtime` | medium | 0 | 6 | accept |
| D | `lib/common/consts/app_consts.dart` | `common_runtime` | medium | 0 | 167 | accept |
| D | `lib/common/global/initial_services.dart` | `common_runtime` | medium | 0 | 112 | accept |
| D | `lib/common/global/win_auto_start.dart` | `common_runtime` | medium | 0 | 125 | accept |
| D | `lib/common/index.dart` | `common_runtime` | medium | 0 | 41 | accept |
| D | `lib/common/services/index.dart` | `common_runtime` | medium | 0 | 4 | accept |
| D | `lib/common/services/settings_service.dart` | `common_runtime` | medium | 0 | 83 | accept |
| D | `lib/common/style/index.dart` | `common_runtime` | medium | 0 | 3 | accept |
| D | `lib/common/utils/cache_manager.dart` | `common_runtime` | medium | 0 | 1 | accept |
| D | `lib/common/utils/index.dart` | `common_runtime` | medium | 0 | 9 | accept |
| D | `lib/common/utils/play_quality_label.dart` | `common_runtime` | medium | 0 | 9 | accept |
| D | `lib/common/utils/text_util.dart` | `common_runtime` | medium | 0 | 19 | accept |
| D | `lib/common/widgets/scrollable_tab_bar.dart` | `common_runtime` | medium | 0 | 187 | accept |
| D | `lib/core/common/hls_session_cookies.dart` | `platform_interfaces` | high | 0 | 126 | accept |
| D | `lib/core/common/hls_source_query_policy.dart` | `platform_interfaces` | high | 0 | 85 | accept |
| R093 | `lib/core/config/app_settings_controller.dart` | `platform_interfaces` | high | None | None | accept |
| R097 | `lib/core/config/cache_controller.dart` | `platform_interfaces` | high | None | None | accept |
| R058 | `lib/core/config/cookie_settings_controller.dart` | `platform_interfaces` | high | None | None | accept |
| R074 | `lib/core/config/danmaku_settings_controller.dart` | `platform_interfaces` | high | None | None | accept |
| R100 | `lib/core/config/display_mode_service.dart` | `platform_interfaces` | high | None | None | accept |
| R099 | `lib/core/config/exit_settings_controller.dart` | `platform_interfaces` | high | None | None | accept |
| A | `lib/core/config/float_window_geometry.dart` | `platform_interfaces` | high | 58 | 0 | accept |
| R093 | `lib/core/config/font_settings_controller.dart` | `platform_interfaces` | high | None | None | accept |
| A | `lib/core/config/index.dart` | `platform_interfaces` | high | 4 | 0 | accept |
| R073 | `lib/core/config/log_controller.dart` | `platform_interfaces` | high | None | None | accept |
| R100 | `lib/core/config/migrations/backup_migration_util.dart` | `platform_interfaces` | high | None | None | accept |
| R099 | `lib/core/config/migrations/settings_upgrade_migration.dart` | `platform_interfaces` | high | None | None | accept |
| R099 | `lib/core/config/page_settings_controller.dart` | `platform_interfaces` | high | None | None | accept |
| R063 | `lib/core/config/player_settings_controller.dart` | `platform_interfaces` | high | None | None | accept |
| R076 | `lib/core/config/proxy_settings_controller.dart` | `platform_interfaces` | high | None | None | accept |
| R095 | `lib/core/config/refresh_config_controller.dart` | `platform_interfaces` | high | None | None | accept |
| R098 | `lib/core/config/room_card_settings_controller.dart` | `platform_interfaces` | high | None | None | accept |
| A | `lib/core/config/settings_service.dart` | `platform_interfaces` | high | 36 | 0 | accept |
| R094 | `lib/core/config/startup_controller.dart` | `platform_interfaces` | high | None | None | accept |
| R094 | `lib/core/config/theme_settings_controller.dart` | `platform_interfaces` | high | None | None | accept |
| R096 | `lib/core/config/volume_settings_controller.dart` | `platform_interfaces` | high | None | None | accept |
| R064 | `lib/core/config/window_size_controller.dart` | `platform_interfaces` | high | None | None | accept |
| A | `lib/core/consts/app_consts.dart` | `platform_interfaces` | high | 172 | 0 | accept |
| A | `lib/core/consts/background_source.dart` | `platform_interfaces` | high | 17 | 0 | accept |
| A | `lib/core/consts/platform_ids.dart` | `platform_interfaces` | high | 15 | 0 | accept |
| D | `lib/core/danmaku/douyu_danmaku.dart` | `platform_interfaces` | high | 0 | 320 | accept |
| D | `lib/core/danmaku/goodgame_danmaku.dart` | `platform_interfaces` | high | 0 | 171 | accept |
| D | `lib/core/danmaku/kick_danmaku.dart` | `platform_interfaces` | high | 0 | 186 | accept |
| D | `lib/core/emoji/models/unified_emoji_model.dart` | `platform_interfaces` | high | 0 | 80 | accept |
| M | `lib/core/index.dart` | `platform_interfaces` | high | 29 | 1 | accept |
| D | `lib/core/iptv/local/epg_channel_identity.dart` | `platform_interfaces` | high | 0 | 5 | accept |
| D | `lib/core/iptv/models/models.dart` | `platform_interfaces` | high | 0 | 1 | accept |
| R095 | `lib/core/logging/app_log.dart` | `platform_interfaces` | high | None | None | accept |
| R093 | `lib/core/logging/core_log.dart` | `platform_interfaces` | high | None | None | accept |
| R100 | `lib/core/models/app_refresh_rate_mode.dart` | `platform_interfaces` | high | None | None | accept |
| A | `lib/core/models/background_config.dart` | `platform_interfaces` | high | 151 | 0 | accept |
| R100 | `lib/core/models/bilibili_user_info_page.dart` | `platform_interfaces` | high | None | None | accept |
| R098 | `lib/core/models/download_state.dart` | `platform_interfaces` | high | None | None | accept |
| R100 | `lib/core/models/font_model.dart` | `platform_interfaces` | high | None | None | accept |
| R100 | `lib/core/models/index.dart` | `platform_interfaces` | high | None | None | accept |
| R088 | `lib/core/models/live_anchor_item.dart` | `platform_interfaces` | high | None | None | accept |
| R100 | `lib/core/models/live_area.dart` | `platform_interfaces` | high | None | None | accept |
| R086 | `lib/core/models/live_category.dart` | `platform_interfaces` | high | None | None | accept |
| R074 | `lib/core/models/live_message.dart` | `platform_interfaces` | high | None | None | accept |
| R085 | `lib/core/models/live_play_quality.dart` | `platform_interfaces` | high | None | None | accept |
| R088 | `lib/core/models/live_room.dart` | `platform_interfaces` | high | None | None | accept |
| R100 | `lib/core/models/refresh_config_model.dart` | `platform_interfaces` | high | None | None | accept |
| R100 | `lib/core/models/release_model.dart` | `platform_interfaces` | high | None | None | accept |
| R080 | `lib/core/navigation/app_navigator.dart` | `platform_interfaces` | high | None | None | accept |
| R066 | `lib/core/navigation/current_route.dart` | `platform_interfaces` | high | None | None | accept |
| A | `lib/core/navigation/official_category_policy.dart` | `platform_interfaces` | high | 10 | 0 | accept |
| R082 | `lib/core/navigation/route_path.dart` | `platform_interfaces` | high | None | None | accept |
| R100 | `lib/core/network/android_native_http.dart` | `platform_interfaces` | high | None | None | accept |
| R100 | `lib/core/network/cookie_sanitizer.dart` | `platform_interfaces` | high | None | None | accept |
| R056 | `lib/core/network/core_error.dart` | `platform_interfaces` | high | None | None | accept |
| R098 | `lib/core/network/custom_interceptor.dart` | `platform_interfaces` | high | None | None | accept |
| A | `lib/core/network/douyu_utils.dart` | `platform_interfaces` | high | 651 | 0 | accept |
| R089 | `lib/core/network/fake_user_agent.dart` | `platform_interfaces` | high | None | None | accept |
| R074 | `lib/core/network/http_client.dart` | `platform_interfaces` | high | None | None | accept |
| R100 | `lib/core/network/http_header_policy.dart` | `platform_interfaces` | high | None | None | accept |
| R098 | `lib/core/network/image_cache_manager.dart` | `platform_interfaces` | high | None | None | accept |
| R100 | `lib/core/network/network_image_url.dart` | `platform_interfaces` | high | None | None | accept |
| R058 | `lib/core/network/proxy_routing.dart` | `platform_interfaces` | high | None | None | accept |
| R100 | `lib/core/network/race_http.dart` | `platform_interfaces` | high | None | None | accept |
| R100 | `lib/core/network/request_scope.dart` | `platform_interfaces` | high | None | None | accept |
| A | `lib/core/network/site_transport_failure.dart` | `platform_interfaces` | high | 31 | 0 | accept |
| R100 | `lib/core/network/web_socket_util.dart` | `platform_interfaces` | high | None | None | accept |
| A | `lib/core/network/webview_proxy_scope.dart` | `platform_interfaces` | high | 74 | 0 | accept |
| R096 | `lib/core/pagination/base_controller.dart` | `platform_interfaces` | high | None | None | accept |
| R087 | `lib/core/pagination/base_page_scroll_bone.dart` | `platform_interfaces` | high | None | None | accept |
| R097 | `lib/core/pagination/base_page_view.dart` | `platform_interfaces` | high | None | None | accept |
| R083 | `lib/core/pagination/base_page_view_extension.dart` | `platform_interfaces` | high | None | None | accept |
| R097 | `lib/core/pagination/desktop_components.dart` | `platform_interfaces` | high | None | None | accept |
| A | `lib/core/pagination/index.dart` | `platform_interfaces` | high | 12 | 0 | accept |
| R095 | `lib/core/pagination/local_reactive_page_controller.dart` | `platform_interfaces` | high | None | None | accept |
| R095 | `lib/core/pagination/server_all_page_controller.dart` | `platform_interfaces` | high | None | None | accept |
| R095 | `lib/core/pagination/server_fixed_page_controller.dart` | `platform_interfaces` | high | None | None | accept |
| R095 | `lib/core/pagination/server_remote_page_controller.dart` | `platform_interfaces` | high | None | None | accept |
| R097 | `lib/core/platform/app_path_manager.dart` | `platform_interfaces` | high | None | None | accept |
| A | `lib/core/platform/desktop_exit_port.dart` | `platform_interfaces` | high | 19 | 0 | accept |
| R084 | `lib/core/platform/desktop_manager.dart` | `platform_interfaces` | high | None | None | accept |
| R069 | `lib/core/platform/desktop_tray_service.dart` | `platform_interfaces` | high | None | None | accept |
| R087 | `lib/core/platform/file_utils.dart` | `platform_interfaces` | high | None | None | accept |
| R096 | `lib/core/platform/font_download_manager.dart` | `platform_interfaces` | high | None | None | accept |
| A | `lib/core/platform/initial_room_handoff.dart` | `platform_interfaces` | high | 13 | 0 | accept |
| A | `lib/core/platform/local_network_access.dart` | `platform_interfaces` | high | 42 | 0 | accept |
| R097 | `lib/core/platform/mobile_manager.dart` | `platform_interfaces` | high | None | None | accept |
| A | `lib/core/platform/multi_instance_settings_source.dart` | `platform_interfaces` | high | 11 | 0 | accept |
| R099 | `lib/core/platform/platform_utils.dart` | `platform_interfaces` | high | None | None | accept |
| R096 | `lib/core/platform/share_command_codec.dart` | `platform_interfaces` | high | None | None | accept |
| R093 | `lib/core/platform/share_command_handler.dart` | `platform_interfaces` | high | None | None | accept |
| A | `lib/core/platform/win_auto_start.dart` | `platform_interfaces` | high | 84 | 0 | accept |
| R066 | `lib/core/platform/windows_multi_instance_launcher.dart` | `platform_interfaces` | high | None | None | accept |
| R100 | `lib/core/platform/windows_portable_path_provider.dart` | `platform_interfaces` | high | None | None | accept |
| A | `lib/core/platform/windows_system_proxy.dart` | `platform_interfaces` | high | 81 | 0 | accept |
| A | `lib/core/player/core/audio_only_mode_policy.dart` | `platform_interfaces` | high | 3 | 0 | accept |
| R100 | `lib/core/player/core/background_playback_policy.dart` | `platform_interfaces` | high | None | None | accept |
| R094 | `lib/core/player/core/background_playback_service.dart` | `platform_interfaces` | high | None | None | accept |
| A | `lib/core/player/core/dummy_video_policy.dart` | `platform_interfaces` | high | 12 | 0 | accept |
| A | `lib/core/player/core/ingest_ffmpeg_registry.dart` | `platform_interfaces` | high | 23 | 0 | accept |
| A | `lib/core/player/core/live_audio_service.dart` | `platform_interfaces` | high | 146 | 0 | accept |
| A | `lib/core/player/core/live_message_normalization.dart` | `platform_interfaces` | high | 22 | 0 | accept |
| R058 | `lib/core/player/core/live_room_volume_manager.dart` | `platform_interfaces` | high | None | None | accept |
| R057 | `lib/core/player/core/media_kit_player_accessor.dart` | `platform_interfaces` | high | None | None | accept |
| A | `lib/core/player/core/playback_input_lease.dart` | `platform_interfaces` | high | 37 | 0 | accept |
| R100 | `lib/core/player/core/playback_lifecycle_coordinator.dart` | `platform_interfaces` | high | None | None | accept |
| R058 | `lib/core/player/core/playback_proxy_policy.dart` | `platform_interfaces` | high | None | None | accept |
| R094 | `lib/core/player/core/playback_source.dart` | `platform_interfaces` | high | None | None | accept |
| A | `lib/core/player/core/playback_source_hints.dart` | `platform_interfaces` | high | 40 | 0 | accept |
| A | `lib/core/player/core/portrait_stream_support.dart` | `platform_interfaces` | high | 65 | 0 | accept |
| A | `lib/core/player/kernel/floating_handle_keeper.dart` | `platform_interfaces` | high | 85 | 0 | accept |
| A | `lib/core/player/kernel/floating_playback.dart` | `platform_interfaces` | high | 301 | 0 | accept |
| A | `lib/core/player/kernel/media_kit_live_properties.dart` | `platform_interfaces` | high | 248 | 0 | accept |
| A | `lib/core/player/kernel/mpv_log_forwarder.dart` | `platform_interfaces` | high | 13 | 0 | accept |
| A | `lib/core/player/kernel/mpv_option_labels.dart` | `platform_interfaces` | high | 129 | 0 | accept |
| A | `lib/core/player/kernel/mpv_platform_profile.dart` | `platform_interfaces` | high | 186 | 0 | accept |
| A | `lib/core/player/kernel/open_volume.dart` | `platform_interfaces` | high | 31 | 0 | accept |
| A | `lib/core/player/kernel/owned_input_opener.dart` | `platform_interfaces` | high | 46 | 0 | accept |
| A | `lib/core/player/kernel/player_consts.dart` | `platform_interfaces` | high | 34 | 0 | accept |
| A | `lib/core/player/kernel/player_kernel_service.dart` | `platform_interfaces` | high | 116 | 0 | accept |
| A | `lib/core/player/kernel/player_preset.dart` | `platform_interfaces` | high | 221 | 0 | accept |
| R097 | `lib/core/player/models/player_engine.dart` | `platform_interfaces` | high | None | None | accept |
| R099 | `lib/core/player/presentation/active_video_content_analyzer.dart` | `platform_interfaces` | high | None | None | accept |
| R059 | `lib/core/player/presentation/android_predictive_back_service.dart` | `platform_interfaces` | high | None | None | accept |
| A | `lib/core/player/presentation/compact_playback_progress.dart` | `platform_interfaces` | high | 84 | 0 | accept |
| A | `lib/core/player/presentation/compact_source_orientation.dart` | `platform_interfaces` | high | 12 | 0 | accept |
| R085 | `lib/core/player/presentation/danmaku/danmaku_settings_content.dart` | `platform_interfaces` | high | None | None | accept |
| A | `lib/core/player/presentation/danmaku/danmaku_surface_settings.dart` | `platform_interfaces` | high | 167 | 0 | accept |
| R099 | `lib/core/player/presentation/danmaku/danmaku_viewing_preset.dart` | `platform_interfaces` | high | None | None | accept |
| A | `lib/core/player/presentation/danmaku/player_danmaku_actions.dart` | `platform_interfaces` | high | 288 | 0 | accept |
| A | `lib/core/player/presentation/danmaku/player_danmaku_surface.dart` | `platform_interfaces` | high | 96 | 0 | accept |
| A | `lib/core/player/presentation/fullscreen_window.dart` | `platform_interfaces` | high | 167 | 0 | accept |
| A | `lib/core/player/presentation/kernel_floating_window_presenter.dart` | `platform_interfaces` | high | 342 | 0 | accept |
| R075 | `lib/core/player/presentation/media_kit_content_probe.dart` | `platform_interfaces` | high | None | None | accept |
| R095 | `lib/core/player/presentation/pip_window_widget.dart` | `platform_interfaces` | high | None | None | accept |
| A | `lib/core/player/presentation/player_back_scope.dart` | `platform_interfaces` | high | 237 | 0 | accept |
| A | `lib/core/player/presentation/player_presentation_actions.dart` | `platform_interfaces` | high | 87 | 0 | accept |
| A | `lib/core/player/presentation/player_ui_controller.dart` | `platform_interfaces` | high | 318 | 0 | accept |
| A | `lib/core/player/presentation/popup_route_tracker.dart` | `platform_interfaces` | high | 65 | 0 | accept |
| R100 | `lib/core/player/presentation/video_output_size_policy.dart` | `platform_interfaces` | high | None | None | accept |
| A | `lib/core/player/presentation/windows_pip_driver.dart` | `platform_interfaces` | high | 204 | 0 | accept |
| A | `lib/core/player/super_resolution.dart` | `platform_interfaces` | high | 133 | 0 | accept |
| R074 | `lib/core/release/github_mirror.dart` | `platform_interfaces` | high | None | None | adapt |
| R092 | `lib/core/release/release_asset_urls.dart` | `platform_interfaces` | high | None | None | accept |
| A | `lib/core/release/release_history_source.dart` | `platform_interfaces` | high | 13 | 0 | accept |
| R092 | `lib/core/release/version_util.dart` | `platform_interfaces` | high | None | None | accept |
| D | `lib/core/site/dailymotion/dailymotion_api.dart` | `platform_interfaces` | high | 0 | 339 | accept |
| D | `lib/core/site/dailymotion/dailymotion_browser.dart` | `platform_interfaces` | high | 0 | 232 | accept |
| D | `lib/core/site/dailymotion/dailymotion_link.dart` | `platform_interfaces` | high | 0 | 89 | accept |
| D | `lib/core/site/dailymotion/dailymotion_site.dart` | `platform_interfaces` | high | 0 | 235 | accept |
| D | `lib/core/site/douyu/douyu_utils.dart` | `platform_interfaces` | high | 0 | 198 | accept |
| D | `lib/core/site/goodgame/goodgame_api.dart` | `platform_interfaces` | high | 0 | 452 | accept |
| D | `lib/core/site/goodgame/goodgame_link.dart` | `platform_interfaces` | high | 0 | 97 | accept |
| D | `lib/core/site/goodgame/goodgame_site.dart` | `platform_interfaces` | high | 0 | 267 | accept |
| D | `lib/core/site/huajiao/huajiao_api.dart` | `platform_interfaces` | high | 0 | 381 | accept |
| D | `lib/core/site/huajiao/huajiao_link.dart` | `platform_interfaces` | high | 0 | 44 | accept |
| D | `lib/core/site/huajiao/huajiao_site.dart` | `platform_interfaces` | high | 0 | 273 | accept |
| D | `lib/core/site/huya/huya_request_params.dart` | `platform_interfaces` | high | 0 | 23 | accept |
| D | `lib/core/site/kick/kick_api.dart` | `platform_interfaces` | high | 0 | 375 | accept |
| D | `lib/core/site/kick/kick_hls.dart` | `platform_interfaces` | high | 0 | 86 | accept |
| D | `lib/core/site/kick/kick_link.dart` | `platform_interfaces` | high | 0 | 44 | accept |
| D | `lib/core/site/kick/kick_site.dart` | `platform_interfaces` | high | 0 | 231 | accept |
| D | `lib/core/site/langlive/langlive_api.dart` | `platform_interfaces` | high | 0 | 251 | accept |
| D | `lib/core/site/langlive/langlive_link.dart` | `platform_interfaces` | high | 0 | 39 | accept |
| D | `lib/core/site/langlive/langlive_site.dart` | `platform_interfaces` | high | 0 | 187 | accept |
| D | `lib/core/site/niconico/niconico_link.dart` | `platform_interfaces` | high | 0 | 17 | accept |
| D | `lib/core/site/nimotv/nimotv_api.dart` | `platform_interfaces` | high | 0 | 377 | accept |
| D | `lib/core/site/nimotv/nimotv_browser.dart` | `platform_interfaces` | high | 0 | 246 | accept |
| D | `lib/core/site/nimotv/nimotv_link.dart` | `platform_interfaces` | high | 0 | 70 | accept |
| D | `lib/core/site/nimotv/nimotv_site.dart` | `platform_interfaces` | high | 0 | 260 | accept |
| D | `lib/core/site/openrec/openrec_api.dart` | `platform_interfaces` | high | 0 | 426 | accept |
| D | `lib/core/site/openrec/openrec_hls.dart` | `platform_interfaces` | high | 0 | 139 | accept |
| D | `lib/core/site/openrec/openrec_link.dart` | `platform_interfaces` | high | 0 | 55 | accept |
| D | `lib/core/site/openrec/openrec_site.dart` | `platform_interfaces` | high | 0 | 283 | accept |
| D | `lib/core/site/popkontv/popkontv_api.dart` | `platform_interfaces` | high | 0 | 719 | accept |
| D | `lib/core/site/popkontv/popkontv_link.dart` | `platform_interfaces` | high | 0 | 74 | accept |
| D | `lib/core/site/popkontv/popkontv_site.dart` | `platform_interfaces` | high | 0 | 279 | accept |
| D | `lib/core/site/rumble/rumble_api.dart` | `platform_interfaces` | high | 0 | 412 | accept |
| D | `lib/core/site/rumble/rumble_browser.dart` | `platform_interfaces` | high | 0 | 359 | accept |
| D | `lib/core/site/rumble/rumble_link.dart` | `platform_interfaces` | high | 0 | 80 | accept |
| D | `lib/core/site/rumble/rumble_site.dart` | `platform_interfaces` | high | 0 | 258 | accept |
| D | `lib/core/site/shopeelive/shopeelive_api.dart` | `platform_interfaces` | high | 0 | 507 | accept |
| D | `lib/core/site/shopeelive/shopeelive_browser.dart` | `platform_interfaces` | high | 0 | 133 | accept |
| D | `lib/core/site/shopeelive/shopeelive_link.dart` | `platform_interfaces` | high | 0 | 61 | accept |
| D | `lib/core/site/shopeelive/shopeelive_site.dart` | `platform_interfaces` | high | 0 | 256 | accept |
| D | `lib/core/site/taobaolive/taobao_live_api.dart` | `platform_interfaces` | high | 0 | 695 | accept |
| D | `lib/core/site/taobaolive/taobao_live_link.dart` | `platform_interfaces` | high | 0 | 133 | accept |
| D | `lib/core/site/taobaolive/taobao_live_site.dart` | `platform_interfaces` | high | 0 | 228 | accept |
| D | `lib/core/site/tting/tting_api.dart` | `platform_interfaces` | high | 0 | 380 | accept |
| D | `lib/core/site/tting/tting_link.dart` | `platform_interfaces` | high | 0 | 27 | accept |
| D | `lib/core/site/tting/tting_site.dart` | `platform_interfaces` | high | 0 | 225 | accept |
| D | `lib/core/site/twitcasting/twitcasting_site.dart` | `platform_interfaces` | high | 0 | 94 | accept |
| D | `lib/core/site/vkvideolive/vkvideolive_api.dart` | `platform_interfaces` | high | 0 | 753 | accept |
| D | `lib/core/site/vkvideolive/vkvideolive_link.dart` | `platform_interfaces` | high | 0 | 54 | accept |
| D | `lib/core/site/vkvideolive/vkvideolive_site.dart` | `platform_interfaces` | high | 0 | 263 | accept |
| D | `lib/core/site/zhanqi/zhanqi_api.dart` | `platform_interfaces` | high | 0 | 346 | accept |
| D | `lib/core/site/zhanqi/zhanqi_link.dart` | `platform_interfaces` | high | 0 | 33 | accept |
| D | `lib/core/site/zhanqi/zhanqi_media_api.dart` | `platform_interfaces` | high | 0 | 631 | accept |
| D | `lib/core/site/zhanqi/zhanqi_player_layout.dart` | `platform_interfaces` | high | 0 | 137 | accept |
| D | `lib/core/site/zhanqi/zhanqi_site.dart` | `platform_interfaces` | high | 0 | 267 | accept |
| R094 | `lib/core/storage/hive_pref_util.dart` | `platform_interfaces` | high | None | None | accept |
| R094 | `lib/core/storage/hive_rx.dart` | `platform_interfaces` | high | None | None | accept |
| R095 | `lib/core/stream/ffmpeg_flv_input_relay.dart` | `platform_interfaces` | high | None | None | accept |
| R100 | `lib/core/stream/hls_master_selection.dart` | `platform_interfaces` | high | None | None | accept |
| A | `lib/core/stream/hls_session_cookies.dart` | `platform_interfaces` | high | 3 | 0 | accept |
| A | `lib/core/stream/hls_source_query_policy.dart` | `platform_interfaces` | high | 3 | 0 | accept |
| A | `lib/core/stream/upstream_proxy_routing.dart` | `platform_interfaces` | high | 11 | 0 | accept |
| R083 | `lib/core/tars/base_tars_http.dart` | `platform_interfaces` | high | None | None | accept |
| R100 | `lib/core/tars/codec/tars_deep_copyable.dart` | `platform_interfaces` | high | None | None | accept |
| R097 | `lib/core/tars/codec/tars_displayer.dart` | `platform_interfaces` | high | None | None | accept |
| A | `lib/core/tars/codec/tars_exceptions.dart` | `platform_interfaces` | high | 15 | 0 | accept |
| R091 | `lib/core/tars/codec/tars_input_stream.dart` | `platform_interfaces` | high | None | None | accept |
| R078 | `lib/core/tars/codec/tars_output_stream.dart` | `platform_interfaces` | high | None | None | accept |
| R086 | `lib/core/tars/codec/tars_struct.dart` | `platform_interfaces` | high | None | None | accept |
| M | `lib/core/tars/game_event_message_board_info.dart` | `platform_interfaces` | high | 4 | 6 | accept |
| M | `lib/core/tars/game_event_message_board_panel.dart` | `platform_interfaces` | high | 4 | 4 | accept |
| M | `lib/core/tars/get_cdn_token_ex_req.dart` | `platform_interfaces` | high | 4 | 5 | accept |
| M | `lib/core/tars/get_cdn_token_ex_resp.dart` | `platform_interfaces` | high | 4 | 4 | accept |
| M | `lib/core/tars/get_game_event_message_board_req.dart` | `platform_interfaces` | high | 4 | 4 | accept |
| M | `lib/core/tars/get_game_event_message_board_rsp.dart` | `platform_interfaces` | high | 4 | 7 | accept |
| R095 | `lib/core/tars/tup/basic_class_type_util.dart` | `platform_interfaces` | high | None | None | accept |
| R100 | `lib/core/tars/tup/const.dart` | `platform_interfaces` | high | None | None | accept |
| R100 | `lib/core/tars/tup/object_create_exception.dart` | `platform_interfaces` | high | None | None | accept |
| R090 | `lib/core/tars/tup/request_packet.dart` | `platform_interfaces` | high | None | None | accept |
| R078 | `lib/core/tars/tup/tars_uni_packet.dart` | `platform_interfaces` | high | None | None | accept |
| R100 | `lib/core/tars/tup/tup_response.dart` | `platform_interfaces` | high | None | None | accept |
| R100 | `lib/core/tars/tup/tup_result_exception.dart` | `platform_interfaces` | high | None | None | accept |
| R090 | `lib/core/tars/tup/uni_attribute.dart` | `platform_interfaces` | high | None | None | accept |
| R085 | `lib/core/tars/tup/uni_packet.dart` | `platform_interfaces` | high | None | None | accept |
| R100 | `lib/core/tars/tup/write_buffer.dart` | `platform_interfaces` | high | None | None | accept |
| M | `lib/core/tars/types.dart` | `platform_interfaces` | high | 4 | 4 | accept |
| A | `lib/core/theme/app_canvas_scope.dart` | `platform_interfaces` | high | 38 | 0 | accept |
| R069 | `lib/core/theme/app_text_styles.dart` | `platform_interfaces` | high | None | None | accept |
| R100 | `lib/core/theme/dynamic_color_adapter.dart` | `platform_interfaces` | high | None | None | accept |
| A | `lib/core/theme/index.dart` | `platform_interfaces` | high | 4 | 0 | accept |
| R095 | `lib/core/theme/theme.dart` | `platform_interfaces` | high | None | None | accept |
| R082 | `lib/core/utils/action_scope.dart` | `platform_interfaces` | high | None | None | accept |
| R077 | `lib/core/utils/binary_writer.dart` | `platform_interfaces` | high | None | None | accept |
| R100 | `lib/core/utils/bounded_async_pool.dart` | `platform_interfaces` | high | None | None | accept |
| R092 | `lib/core/utils/event_bus.dart` | `platform_interfaces` | high | None | None | accept |
| R100 | `lib/core/utils/i18n.dart` | `platform_interfaces` | high | None | None | accept |
| A | `lib/core/utils/index.dart` | `platform_interfaces` | high | 8 | 0 | accept |
| A | `lib/core/utils/invisible_placeholders.dart` | `platform_interfaces` | high | 8 | 0 | accept |
| R100 | `lib/core/utils/latest_async_value_queue.dart` | `platform_interfaces` | high | None | None | accept |
| R092 | `lib/core/utils/list_util.dart` | `platform_interfaces` | high | None | None | accept |
| M | `lib/core/utils/live_quality_label.dart` | `platform_interfaces` | high | 67 | 4 | accept |
| R087 | `lib/core/utils/shared_media_intake.dart` | `platform_interfaces` | high | None | None | accept |
| R100 | `lib/core/utils/string_to_boolean.dart` | `platform_interfaces` | high | None | None | accept |
| A | `lib/core/utils/text_util.dart` | `platform_interfaces` | high | 17 | 0 | accept |
| R100 | `lib/core/utils/type_cast.dart` | `platform_interfaces` | high | None | None | accept |
| R096 | `lib/core/widgets/adaptive_refresh_rate_scope.dart` | `platform_interfaces` | high | None | None | accept |
| A | `lib/core/widgets/app_prompt_dialogs.dart` | `platform_interfaces` | high | 301 | 0 | accept |
| R099 | `lib/core/widgets/app_status_view.dart` | `platform_interfaces` | high | None | None | accept |
| R093 | `lib/core/widgets/common_appbar_actions.dart` | `platform_interfaces` | high | None | None | accept |
| R089 | `lib/core/widgets/common_avatar.dart` | `platform_interfaces` | high | None | None | accept |
| R095 | `lib/core/widgets/count_button.dart` | `platform_interfaces` | high | None | None | accept |
| R099 | `lib/core/widgets/custom_icons.dart` | `platform_interfaces` | high | None | None | accept |
| R095 | `lib/core/widgets/download_apk_dialog.dart` | `platform_interfaces` | high | None | None | accept |
| R098 | `lib/core/widgets/download_directory_dialog.dart` | `platform_interfaces` | high | None | None | accept |
| R089 | `lib/core/widgets/empty_view.dart` | `platform_interfaces` | high | None | None | accept |
| A | `lib/core/widgets/fitting_sheet_body.dart` | `platform_interfaces` | high | 25 | 0 | accept |
| R070 | `lib/core/widgets/index.dart` | `platform_interfaces` | high | None | None | accept |
| R100 | `lib/core/widgets/keep_alive_wrapper.dart` | `platform_interfaces` | high | None | None | accept |
| R087 | `lib/core/widgets/menu_button.dart` | `platform_interfaces` | high | None | None | accept |
| R100 | `lib/core/widgets/pure_live_scroll_controller.dart` | `platform_interfaces` | high | None | None | accept |
| R100 | `lib/core/widgets/pure_live_scroll_physics.dart` | `platform_interfaces` | high | None | None | accept |
| R100 | `lib/core/widgets/qr_code_widget.dart` | `platform_interfaces` | high | None | None | accept |
| R099 | `lib/core/widgets/refresh_indicators.dart` | `platform_interfaces` | high | None | None | accept |
| A | `lib/core/widgets/scrollable_tab_bar.dart` | `platform_interfaces` | high | 178 | 0 | accept |
| R091 | `lib/core/widgets/search_button.dart` | `platform_interfaces` | high | None | None | accept |
| R100 | `lib/core/widgets/section_list_tile.dart` | `platform_interfaces` | high | None | None | accept |
| R095 | `lib/core/widgets/share_command_import_dialog.dart` | `platform_interfaces` | high | None | None | accept |
| R093 | `lib/core/widgets/snackbar_util.dart` | `platform_interfaces` | high | None | None | accept |
| R100 | `lib/core/widgets/toast_util.dart` | `platform_interfaces` | high | None | None | accept |
| R097 | `lib/core/widgets/widget_extensions.dart` | `platform_interfaces` | high | None | None | accept |
| R087 | `lib/domains/account/data/bilibili_account_service.dart` | `other_application_source` | medium | None | None | accept |
| R086 | `lib/domains/account/presentation/account/account_controller.dart` | `other_application_source` | medium | None | None | accept |
| R075 | `lib/domains/account/presentation/account/account_cookie_editor.dart` | `other_application_source` | medium | None | None | accept |
| R062 | `lib/domains/account/presentation/account/account_page.dart` | `other_application_source` | medium | None | None | accept |
| A | `lib/domains/account/presentation/account/bigo/bigo_cookie_controller.dart` | `other_application_source` | medium | 25 | 0 | accept |
| A | `lib/domains/account/presentation/account/bigo/bigo_cookie_page.dart` | `other_application_source` | medium | 17 | 0 | accept |
| R056 | `lib/domains/account/presentation/account/bilibili/bilibili_bindings.dart` | `other_application_source` | medium | None | None | accept |
| R100 | `lib/domains/account/presentation/account/bilibili/bilibili_login_qr_code.dart` | `other_application_source` | medium | None | None | accept |
| R097 | `lib/domains/account/presentation/account/bilibili/qr_login_controller.dart` | `other_application_source` | medium | None | None | accept |
| R096 | `lib/domains/account/presentation/account/bilibili/qr_login_page.dart` | `other_application_source` | medium | None | None | accept |
| R096 | `lib/domains/account/presentation/account/bilibili/web_login_controller.dart` | `other_application_source` | medium | None | None | accept |
| R097 | `lib/domains/account/presentation/account/bilibili/web_login_page.dart` | `other_application_source` | medium | None | None | accept |
| R056 | `lib/domains/account/presentation/account/douyin/douyin_cookie_controller.dart` | `other_application_source` | medium | None | None | accept |
| R061 | `lib/domains/account/presentation/account/douyin/douyin_cookie_page.dart` | `other_application_source` | medium | None | None | accept |
| A | `lib/domains/account/presentation/account/douyu/douyu_cookie_controller.dart` | `other_application_source` | medium | 201 | 0 | accept |
| A | `lib/domains/account/presentation/account/douyu/douyu_cookie_page.dart` | `other_application_source` | medium | 126 | 0 | accept |
| R056 | `lib/domains/account/presentation/account/huya/huya_cookie_controller.dart` | `other_application_source` | medium | None | None | accept |
| R060 | `lib/domains/account/presentation/account/huya/huya_cookie_page.dart` | `other_application_source` | medium | None | None | accept |
| R056 | `lib/domains/account/presentation/account/kuaishou/kuaishou_cookie_controller.dart` | `other_application_source` | medium | None | None | accept |
| R061 | `lib/domains/account/presentation/account/kuaishou/kuaishou_cookie_page.dart` | `other_application_source` | medium | None | None | accept |
| R057 | `lib/domains/account/presentation/account/soop/soop_cookie_controller.dart` | `other_application_source` | medium | None | None | accept |
| R061 | `lib/domains/account/presentation/account/soop/soop_cookie_page.dart` | `other_application_source` | medium | None | None | accept |
| R057 | `lib/domains/account/presentation/account/twitch/twitch_cookie_controller.dart` | `other_application_source` | medium | None | None | accept |
| R061 | `lib/domains/account/presentation/account/twitch/twitch_cookie_page.dart` | `other_application_source` | medium | None | None | accept |
| R057 | `lib/domains/account/presentation/account/yy/yy_cookie_controller.dart` | `other_application_source` | medium | None | None | accept |
| R063 | `lib/domains/account/presentation/account/yy/yy_cookie_page.dart` | `other_application_source` | medium | None | None | accept |
| R094 | `lib/domains/account/presentation/auth/auth_controller.dart` | `other_application_source` | medium | None | None | accept |
| R096 | `lib/domains/account/presentation/auth/components/firebase_email_auth.dart` | `other_application_source` | medium | None | None | accept |
| R098 | `lib/domains/account/presentation/auth/components/user_detail_main_page.dart` | `other_application_source` | medium | None | None | accept |
| R096 | `lib/domains/account/presentation/auth/mine_page.dart` | `other_application_source` | medium | None | None | accept |
| R095 | `lib/domains/account/presentation/auth/models/policy_model.dart` | `other_application_source` | medium | None | None | accept |
| R100 | `lib/domains/account/presentation/auth/models/user_config_model.dart` | `other_application_source` | medium | None | None | accept |
| R051 | `lib/domains/account/presentation/auth/models/user_item.dart` | `other_application_source` | medium | None | None | accept |
| R086 | `lib/domains/account/presentation/auth/sign_in_page.dart` | `other_application_source` | medium | None | None | accept |
| R095 | `lib/domains/account/presentation/auth/user_manage_page.dart` | `other_application_source` | medium | None | None | accept |
| R100 | `lib/domains/account/presentation/auth/user_management_actions.dart` | `other_application_source` | medium | None | None | accept |
| R095 | `lib/domains/account/presentation/auth/user_server_remote_controller.dart` | `other_application_source` | medium | None | None | accept |
| R100 | `lib/domains/account/presentation/auth/utils/constants.dart` | `other_application_source` | medium | None | None | accept |
| R098 | `lib/domains/account/presentation/auth/utils/firebase_manager.dart` | `other_application_source` | medium | None | None | accept |
| R077 | `lib/domains/iptv/data/iptv_repository.dart` | `other_application_source` | medium | None | None | accept |
| R091 | `lib/domains/iptv/data/iptv_settings_controller.dart` | `other_application_source` | medium | None | None | accept |
| R098 | `lib/domains/iptv/data/local/database.dart` | `other_application_source` | medium | None | None | accept |
| R100 | `lib/domains/iptv/data/local/database.g.dart` | `other_application_source` | medium | None | None | accept |
| R070 | `lib/domains/iptv/data/local/db_service.dart` | `other_application_source` | medium | None | None | accept |
| R100 | `lib/domains/iptv/data/local/tables.dart` | `other_application_source` | medium | None | None | accept |
| R095 | `lib/domains/iptv/data/parsers/json_epg_parser.dart` | `other_application_source` | medium | None | None | accept |
| R096 | `lib/domains/iptv/data/parsers/m3u_parser.dart` | `other_application_source` | medium | None | None | accept |
| R092 | `lib/domains/iptv/data/parsers/txt_parser.dart` | `other_application_source` | medium | None | None | accept |
| R099 | `lib/domains/iptv/data/parsers/xmltv_parser.dart` | `other_application_source` | medium | None | None | accept |
| A | `lib/domains/iptv/data/platforms/iptv_danmaku_capability.dart` | `other_application_source` | medium | 6 | 0 | accept |
| R075 | `lib/domains/iptv/data/platforms/iptv_site.dart` | `other_application_source` | medium | None | None | accept |
| R087 | `lib/domains/iptv/data/playlist_storage.dart` | `other_application_source` | medium | None | None | accept |
| R095 | `lib/domains/iptv/data/provider.dart` | `other_application_source` | medium | None | None | accept |
| R069 | `lib/domains/iptv/data/services/auto_sync_scheduler.dart` | `other_application_source` | medium | None | None | accept |
| R099 | `lib/domains/iptv/data/services/epg_auto_mapper.dart` | `other_application_source` | medium | None | None | accept |
| R092 | `lib/domains/iptv/data/services/epg_import_manager.dart` | `other_application_source` | medium | None | None | accept |
| R087 | `lib/domains/iptv/data/services/epg_sync_engine.dart` | `other_application_source` | medium | None | None | accept |
| R096 | `lib/domains/iptv/data/services/iptv_import_manager.dart` | `other_application_source` | medium | None | None | accept |
| R088 | `lib/domains/iptv/data/services/iptv_sync_engine.dart` | `other_application_source` | medium | None | None | accept |
| R096 | `lib/domains/iptv/data/services/playlist_channel_reconciler.dart` | `other_application_source` | medium | None | None | accept |
| R100 | `lib/domains/iptv/domain/channel.dart` | `other_application_source` | medium | None | None | accept |
| R100 | `lib/domains/iptv/domain/epg.dart` | `other_application_source` | medium | None | None | accept |
| R100 | `lib/domains/iptv/domain/fuzzy_match.dart` | `other_application_source` | medium | None | None | accept |
| R078 | `lib/domains/iptv/domain/playlist_parse_result.dart` | `other_application_source` | medium | None | None | accept |
| R100 | `lib/domains/iptv/domain/show.dart` | `other_application_source` | medium | None | None | accept |
| R092 | `lib/domains/iptv/presentation/channel_detail_controller.dart` | `other_application_source` | medium | None | None | accept |
| R097 | `lib/domains/iptv/presentation/iptv_manage.dart` | `other_application_source` | medium | None | None | accept |
| R094 | `lib/domains/iptv/presentation/iptv_page.dart` | `other_application_source` | medium | None | None | accept |
| R068 | `lib/domains/live/data/direct_link_flow.dart` | `other_application_source` | medium | None | None | accept |
| R087 | `lib/domains/live/data/favorite_room_controller.dart` | `other_application_source` | medium | None | None | accept |
| R092 | `lib/domains/live/data/history_controller.dart` | `other_application_source` | medium | None | None | accept |
| R064 | `lib/domains/live/data/link/live_url_tool.dart` | `other_application_source` | medium | None | None | accept |
| A | `lib/domains/live/data/link/shared_live_link_opener.dart` | `other_application_source` | medium | 65 | 0 | accept |
| R064 | `lib/domains/live/data/link/web_search_room_parser.dart` | `other_application_source` | medium | None | None | accept |
| A | `lib/domains/live/data/platforms/danmaku_emote_loader.dart` | `other_application_source` | medium | 59 | 0 | accept |
| R064 | `lib/domains/live/data/platforms/sites.dart` | `other_application_source` | medium | None | None | accept |
| R066 | `lib/domains/live/data/playback_header_resolver.dart` | `other_application_source` | medium | None | None | accept |
| A | `lib/domains/live/data/stream/flv_legacy_hevc_relay.dart` | `other_application_source` | medium | 189 | 0 | accept |
| A | `lib/domains/live/data/stream/flv_splice_relay.dart` | `other_application_source` | medium | 538 | 0 | accept |
| A | `lib/domains/live/data/stream/ingest_source_interceptor.dart` | `other_application_source` | medium | 44 | 0 | accept |
| A | `lib/domains/live/data/stream/live_stream_ingest.dart` | `other_application_source` | medium | 45 | 0 | accept |
| A | `lib/domains/live/data/stream/playback_ingest_needs.dart` | `other_application_source` | medium | 28 | 0 | accept |
| A | `lib/domains/live/data/stream/playback_manifest_probe.dart` | `other_application_source` | medium | 56 | 0 | accept |
| A | `lib/domains/live/data/stream/playback_source_transport.dart` | `other_application_source` | medium | 409 | 0 | accept |
| A | `lib/domains/live/domain/global_player_service.dart` | `other_application_source` | medium | 70 | 0 | accept |
| A | `lib/domains/live/domain/live_input_playback_binder.dart` | `other_application_source` | medium | 19 | 0 | accept |
| A | `lib/domains/live/domain/live_player_facade.dart` | `other_application_source` | medium | 1109 | 0 | accept |
| A | `lib/domains/live/domain/playback_source_interceptor.dart` | `other_application_source` | medium | 27 | 0 | accept |
| A | `lib/domains/live/domain/playback_source_refresh.dart` | `other_application_source` | medium | 209 | 0 | accept |
| R093 | `lib/domains/live/presentation/area_rooms/area_rooms_controller.dart` | `other_application_source` | medium | None | None | accept |
| R093 | `lib/domains/live/presentation/area_rooms/area_rooms_page.dart` | `other_application_source` | medium | None | None | accept |
| R092 | `lib/domains/live/presentation/areas/area_card.dart` | `other_application_source` | medium | None | None | accept |
| A | `lib/domains/live/presentation/areas/area_display_config.dart` | `other_application_source` | medium | 56 | 0 | accept |
| R096 | `lib/domains/live/presentation/areas/area_pic_mapper.dart` | `other_application_source` | medium | None | None | accept |
| R091 | `lib/domains/live/presentation/areas/areas_controller.dart` | `other_application_source` | medium | None | None | accept |
| R088 | `lib/domains/live/presentation/areas/areas_grid_view.dart` | `other_application_source` | medium | None | None | accept |
| R088 | `lib/domains/live/presentation/areas/areas_list_controller.dart` | `other_application_source` | medium | None | None | accept |
| R089 | `lib/domains/live/presentation/areas/areas_page.dart` | `other_application_source` | medium | None | None | accept |
| R096 | `lib/domains/live/presentation/areas/category_artwork.dart` | `other_application_source` | medium | None | None | accept |
| R059 | `lib/domains/live/presentation/areas/favorite_areas_controller.dart` | `other_application_source` | medium | None | None | accept |
| R091 | `lib/domains/live/presentation/areas/favorite_areas_page.dart` | `other_application_source` | medium | None | None | accept |
| R085 | `lib/domains/live/presentation/favorite/favorite_controller.dart` | `other_application_source` | medium | None | None | accept |
| R093 | `lib/domains/live/presentation/favorite/favorite_page.dart` | `other_application_source` | medium | None | None | accept |
| R097 | `lib/domains/live/presentation/favorite/favorite_startup_policy.dart` | `other_application_source` | medium | None | None | accept |
| R093 | `lib/domains/live/presentation/favorite/room_grid_view.dart` | `other_application_source` | medium | None | None | accept |
| R091 | `lib/domains/live/presentation/history/history_page.dart` | `other_application_source` | medium | None | None | accept |
| R074 | `lib/domains/live/presentation/hot_areas/hot_areas_controller.dart` | `other_application_source` | medium | None | None | accept |
| R094 | `lib/domains/live/presentation/hot_areas/hot_areas_page.dart` | `other_application_source` | medium | None | None | accept |
| R060 | `lib/domains/live/presentation/multiview/danmaku/multiview_danmaku_session.dart` | `other_application_source` | medium | None | None | accept |
| A | `lib/domains/live/presentation/multiview/danmaku/multiview_danmaku_settings_source.dart` | `other_application_source` | medium | 13 | 0 | accept |
| R056 | `lib/domains/live/presentation/multiview/models/multiview_models.dart` | `other_application_source` | medium | None | None | accept |
| A | `lib/domains/live/presentation/multiview/multiview_controller.dart` | `other_application_source` | medium | 997 | 0 | accept |
| R076 | `lib/domains/live/presentation/multiview/multiview_page.dart` | `other_application_source` | medium | None | None | accept |
| R100 | `lib/domains/live/presentation/multiview/widgets/focus_rail_visibility.dart` | `other_application_source` | medium | None | None | accept |
| R085 | `lib/domains/live/presentation/multiview/widgets/multiview_fullscreen_surface.dart` | `other_application_source` | medium | None | None | accept |
| R086 | `lib/domains/live/presentation/multiview/widgets/multiview_room_picker.dart` | `other_application_source` | medium | None | None | accept |
| R098 | `lib/domains/live/presentation/multiview/widgets/video_output_viewport_sizer.dart` | `other_application_source` | medium | None | None | accept |
| R098 | `lib/domains/live/presentation/pagination/live_directory_controller.dart` | `other_application_source` | medium | None | None | accept |
| R069 | `lib/domains/live/presentation/playback/controllers/danmaku_controller.dart` | `other_application_source` | medium | None | None | accept |
| R100 | `lib/domains/live/presentation/playback/controllers/danmaku_presentation_recovery.dart` | `other_application_source` | medium | None | None | accept |
| A | `lib/domains/live/presentation/playback/controllers/danmaku_session_host.dart` | `other_application_source` | medium | 36 | 0 | accept |
| R080 | `lib/domains/live/presentation/playback/controllers/live_play_controller.dart` | `other_application_source` | medium | None | None | accept |
| R083 | `lib/domains/live/presentation/playback/controllers/player_controller.dart` | `other_application_source` | medium | None | None | accept |
| R096 | `lib/domains/live/presentation/playback/controllers/timer_controller.dart` | `other_application_source` | medium | None | None | accept |
| R076 | `lib/domains/live/presentation/playback/dialogs/known_room_link_dialog.dart` | `other_application_source` | medium | None | None | accept |
| R099 | `lib/domains/live/presentation/playback/dialogs/live_dlna_dialog.dart` | `other_application_source` | medium | None | None | accept |
| R077 | `lib/domains/live/presentation/playback/dialogs/play_other.dart` | `other_application_source` | medium | None | None | accept |
| R096 | `lib/domains/live/presentation/playback/dialogs/room_timer_dialog.dart` | `other_application_source` | medium | None | None | accept |
| R098 | `lib/domains/live/presentation/playback/dialogs/room_volume_dialog.dart` | `other_application_source` | medium | None | None | accept |
| A | `lib/domains/live/presentation/playback/pages/danmaku_settings_page.dart` | `other_application_source` | medium | 9 | 0 | accept |
| R097 | `lib/domains/live/presentation/playback/pages/keyword_block_page.dart` | `other_application_source` | medium | None | None | accept |
| R067 | `lib/domains/live/presentation/playback/pages/live_play_page.dart` | `other_application_source` | medium | None | None | accept |
| R092 | `lib/domains/live/presentation/playback/pages/super_chat_page.dart` | `other_application_source` | medium | None | None | accept |
| A | `lib/domains/live/presentation/playback/services/room_external_opener.dart` | `other_application_source` | medium | 54 | 0 | accept |
| R093 | `lib/domains/live/presentation/playback/states/danmaku_state.dart` | `other_application_source` | medium | None | None | accept |
| R100 | `lib/domains/live/presentation/playback/states/live_play_state.dart` | `other_application_source` | medium | None | None | accept |
| R082 | `lib/domains/live/presentation/playback/states/player_state.dart` | `other_application_source` | medium | None | None | accept |
| R091 | `lib/domains/live/presentation/playback/states/room_state.dart` | `other_application_source` | medium | None | None | accept |
| R100 | `lib/domains/live/presentation/playback/states/ui_state.dart` | `other_application_source` | medium | None | None | accept |
| R089 | `lib/domains/live/presentation/playback/widgets/button/favorite_floating_button.dart` | `other_application_source` | medium | None | None | accept |
| R082 | `lib/domains/live/presentation/playback/widgets/button/live_play_menu_button.dart` | `other_application_source` | medium | None | None | accept |
| R079 | `lib/domains/live/presentation/playback/widgets/content_first_panel_layout.dart` | `other_application_source` | medium | None | None | accept |
| R072 | `lib/domains/live/presentation/playback/widgets/danmaku/compact_danmaku_metrics.dart` | `other_application_source` | medium | None | None | accept |
| A | `lib/domains/live/presentation/playback/widgets/danmaku/compact_danmaku_overlay.dart` | `other_application_source` | medium | 143 | 0 | accept |
| R100 | `lib/domains/live/presentation/playback/widgets/danmaku/danmaku_arrival_counter.dart` | `other_application_source` | medium | None | None | accept |
| R079 | `lib/domains/live/presentation/playback/widgets/danmaku/danmaku_list_view.dart` | `other_application_source` | medium | None | None | accept |
| R092 | `lib/domains/live/presentation/playback/widgets/danmaku/danmaku_message_actions.dart` | `other_application_source` | medium | None | None | accept |
| A | `lib/domains/live/presentation/playback/widgets/danmaku/danmaku_settings_source.dart` | `other_application_source` | medium | 8 | 0 | accept |
| R077 | `lib/domains/live/presentation/playback/widgets/danmaku/danmaku_tab.dart` | `other_application_source` | medium | None | None | accept |
| A | `lib/domains/live/presentation/playback/widgets/danmaku/danmaku_viewing_preset.dart` | `other_application_source` | medium | 8 | 0 | accept |
| A | `lib/domains/live/presentation/playback/widgets/danmaku/portrait_danmaku_policy.dart` | `other_application_source` | medium | 8 | 0 | accept |
| A | `lib/domains/live/presentation/playback/widgets/keyboard/video_keyboard.dart` | `other_application_source` | medium | 216 | 0 | accept |
| R100 | `lib/domains/live/presentation/playback/widgets/layout/bottom_control_surface.dart` | `other_application_source` | medium | None | None | accept |
| R100 | `lib/domains/live/presentation/playback/widgets/layout/control_hover_region.dart` | `other_application_source` | medium | None | None | accept |
| R093 | `lib/domains/live/presentation/playback/widgets/layout/live_play_content.dart` | `other_application_source` | medium | None | None | accept |
| R082 | `lib/domains/live/presentation/playback/widgets/layout/live_play_header.dart` | `other_application_source` | medium | None | None | accept |
| A | `lib/domains/live/presentation/playback/widgets/layout/live_play_video.dart` | `other_application_source` | medium | 131 | 0 | accept |
| R099 | `lib/domains/live/presentation/playback/widgets/layout/portrait_fullscreen_interaction.dart` | `other_application_source` | medium | None | None | accept |
| R098 | `lib/domains/live/presentation/playback/widgets/layout/super_chat_card.dart` | `other_application_source` | medium | None | None | accept |
| R099 | `lib/domains/live/presentation/playback/widgets/local_interaction/local_danmaku_style_editor.dart` | `other_application_source` | medium | None | None | accept |
| R090 | `lib/domains/live/presentation/playback/widgets/local_interaction/local_interaction_controller.dart` | `other_application_source` | medium | None | None | accept |
| R096 | `lib/domains/live/presentation/playback/widgets/local_interaction/local_interaction_sheet.dart` | `other_application_source` | medium | None | None | accept |
| R086 | `lib/domains/live/presentation/playback/widgets/local_interaction/local_message_delivery_queue.dart` | `other_application_source` | medium | None | None | accept |
| R083 | `lib/domains/live/presentation/playback/widgets/placeholder/not_living_video_widget.dart` | `other_application_source` | medium | None | None | accept |
| R090 | `lib/domains/live/presentation/playback/widgets/resolution_selector/audience_info.dart` | `other_application_source` | medium | None | None | accept |
| R092 | `lib/domains/live/presentation/playback/widgets/resolution_selector/line_selector.dart` | `other_application_source` | medium | None | None | accept |
| R091 | `lib/domains/live/presentation/playback/widgets/resolution_selector/resolution_selector.dart` | `other_application_source` | medium | None | None | accept |
| R089 | `lib/domains/live/presentation/playback/widgets/resolution_selector/resolutions_row.dart` | `other_application_source` | medium | None | None | accept |
| A | `lib/domains/live/presentation/playback/widgets/video_player/audio_only_presentation.dart` | `other_application_source` | medium | 151 | 0 | accept |
| A | `lib/domains/live/presentation/playback/widgets/video_player/dummy_video_cover.dart` | `other_application_source` | medium | 71 | 0 | accept |
| R100 | `lib/domains/live/presentation/playback/widgets/video_player/iptv_programme_policy.dart` | `other_application_source` | medium | None | None | accept |
| R097 | `lib/domains/live/presentation/playback/widgets/video_player/iptv_schedule_dialog.dart` | `other_application_source` | medium | None | None | accept |
| A | `lib/domains/live/presentation/playback/widgets/video_player/picture_cover.dart` | `other_application_source` | medium | 11 | 0 | accept |
| R098 | `lib/domains/live/presentation/playback/widgets/video_player/playback_failure_overlay.dart` | `other_application_source` | medium | None | None | accept |
| R098 | `lib/domains/live/presentation/playback/widgets/video_player/portrait_playback_picker_dialog.dart` | `other_application_source` | medium | None | None | accept |
| R079 | `lib/domains/live/presentation/playback/widgets/video_player/video_controller.dart` | `other_application_source` | medium | None | None | accept |
| R073 | `lib/domains/live/presentation/playback/widgets/video_player/video_controller_panel.dart` | `other_application_source` | medium | None | None | accept |
| R090 | `lib/domains/live/presentation/playback/widgets/video_player/video_loading.dart` | `other_application_source` | medium | None | None | accept |
| R058 | `lib/domains/live/presentation/playback/widgets/video_player/video_player.dart` | `other_application_source` | medium | None | None | accept |
| R094 | `lib/domains/live/presentation/playback/widgets/video_player/volume_control.dart` | `other_application_source` | medium | None | None | accept |
| R094 | `lib/domains/live/presentation/popular/popular_controller.dart` | `other_application_source` | medium | None | None | accept |
| R097 | `lib/domains/live/presentation/popular/popular_grid_controller.dart` | `other_application_source` | medium | None | None | accept |
| R097 | `lib/domains/live/presentation/popular/popular_grid_view.dart` | `other_application_source` | medium | None | None | accept |
| R077 | `lib/domains/live/presentation/popular/popular_page.dart` | `other_application_source` | medium | None | None | accept |
| R074 | `lib/domains/live/presentation/search/search_capability.dart` | `other_application_source` | medium | None | None | accept |
| R096 | `lib/domains/live/presentation/search/search_controller.dart` | `other_application_source` | medium | None | None | accept |
| R080 | `lib/domains/live/presentation/search/search_page.dart` | `other_application_source` | medium | None | None | accept |
| R085 | `lib/domains/live/presentation/search/search_platform_strip.dart` | `other_application_source` | medium | None | None | accept |
| R080 | `lib/domains/live/presentation/search/search_ranking.dart` | `other_application_source` | medium | None | None | accept |
| R096 | `lib/domains/live/presentation/search/web_search_controller.dart` | `other_application_source` | medium | None | None | accept |
| R098 | `lib/domains/live/presentation/search/web_search_page.dart` | `other_application_source` | medium | None | None | accept |
| R073 | `lib/domains/live/presentation/shield/danmu_shield_controller.dart` | `other_application_source` | medium | None | None | accept |
| R093 | `lib/domains/live/presentation/shield/danmu_shield_page.dart` | `other_application_source` | medium | None | None | accept |
| R095 | `lib/domains/live/presentation/tags/live_tag.dart` | `other_application_source` | medium | None | None | accept |
| R093 | `lib/domains/live/presentation/tags/tag_management_controller.dart` | `other_application_source` | medium | None | None | accept |
| R099 | `lib/domains/live/presentation/tags/tag_management_page.dart` | `other_application_source` | medium | None | None | accept |
| A | `lib/domains/live/presentation/widgets/platform_tab.dart` | `other_application_source` | medium | 65 | 0 | accept |
| R098 | `lib/domains/live/presentation/widgets/room_card.dart` | `other_application_source` | medium | None | None | accept |
| R095 | `lib/domains/live/presentation/widgets/room_card_layout.dart` | `other_application_source` | medium | None | None | accept |
| R088 | `lib/domains/recorder/data/consts/recorder_config.dart` | `other_application_source` | medium | None | None | accept |
| R066 | `lib/domains/recorder/data/consts/recorder_keys.dart` | `other_application_source` | medium | None | None | accept |
| R099 | `lib/domains/recorder/data/ffmpeg/ffmpeg_command_builder.dart` | `other_application_source` | medium | None | None | accept |
| R085 | `lib/domains/recorder/data/ffmpeg/ffmpeg_event.dart` | `other_application_source` | medium | None | None | accept |
| R080 | `lib/domains/recorder/data/ffmpeg/ffmpeg_manager.dart` | `other_application_source` | medium | None | None | accept |
| R088 | `lib/domains/recorder/data/ffmpeg/ffmpeg_scheduler.dart` | `other_application_source` | medium | None | None | accept |
| R100 | `lib/domains/recorder/data/ffmpeg/ffmpeg_types.dart` | `other_application_source` | medium | None | None | accept |
| R084 | `lib/domains/recorder/data/record_settings_controller.dart` | `other_application_source` | medium | None | None | accept |
| R093 | `lib/domains/recorder/data/services/bigo_hls_input.dart` | `other_application_source` | medium | None | None | accept |
| R087 | `lib/domains/recorder/data/services/cache_service.dart` | `other_application_source` | medium | None | None | accept |
| R100 | `lib/domains/recorder/data/services/cancellable_http_connections.dart` | `other_application_source` | medium | None | None | accept |
| R089 | `lib/domains/recorder/data/services/fc2_hls_input.dart` | `other_application_source` | medium | None | None | accept |
| R080 | `lib/domains/recorder/data/services/ffmpeg_header_factory.dart` | `other_application_source` | medium | None | None | accept |
| R096 | `lib/domains/recorder/data/services/ffmpeg_hls_input_relay.dart` | `other_application_source` | medium | None | None | accept |
| A | `lib/domains/recorder/data/services/ffmpeg_ingest_starter.dart` | `other_application_source` | medium | 47 | 0 | accept |
| R095 | `lib/domains/recorder/data/services/ffmpeg_service.dart` | `other_application_source` | medium | None | None | accept |
| R098 | `lib/domains/recorder/data/services/ffmpeg_tls_trust_store.dart` | `other_application_source` | medium | None | None | accept |
| R100 | `lib/domains/recorder/data/services/hls_body_reader.dart` | `other_application_source` | medium | None | None | accept |
| R100 | `lib/domains/recorder/data/services/hls_date_range.dart` | `other_application_source` | medium | None | None | accept |
| R100 | `lib/domains/recorder/data/services/hls_http_body_metadata.dart` | `other_application_source` | medium | None | None | accept |
| R100 | `lib/domains/recorder/data/services/hls_low_latency.dart` | `other_application_source` | medium | None | None | accept |
| R100 | `lib/domains/recorder/data/services/hls_media_spool.dart` | `other_application_source` | medium | None | None | accept |
| R100 | `lib/domains/recorder/data/services/hls_prefetch_plan.dart` | `other_application_source` | medium | None | None | accept |
| R100 | `lib/domains/recorder/data/services/hls_prefetch_pool.dart` | `other_application_source` | medium | None | None | accept |
| R100 | `lib/domains/recorder/data/services/hls_prefetch_scheduler.dart` | `other_application_source` | medium | None | None | accept |
| R100 | `lib/domains/recorder/data/services/hls_relay_diagnostics.dart` | `other_application_source` | medium | None | None | accept |
| R100 | `lib/domains/recorder/data/services/hls_relay_prefetch.dart` | `other_application_source` | medium | None | None | accept |
| R100 | `lib/domains/recorder/data/services/hls_retained_manifest.dart` | `other_application_source` | medium | None | None | accept |
| R100 | `lib/domains/recorder/data/services/hls_retained_window.dart` | `other_application_source` | medium | None | None | accept |
| R098 | `lib/domains/recorder/data/services/hls_upstream_client.dart` | `other_application_source` | medium | None | None | accept |
| A | `lib/domains/recorder/data/services/live_input_playback_binding.dart` | `other_application_source` | medium | 161 | 0 | accept |
| R073 | `lib/domains/recorder/data/services/live_input_recording_binder.dart` | `other_application_source` | medium | None | None | accept |
| R095 | `lib/domains/recorder/data/services/niconico_hls_input.dart` | `other_application_source` | medium | None | None | accept |
| R100 | `lib/domains/recorder/data/services/owned_record_input.dart` | `other_application_source` | medium | None | None | accept |
| R092 | `lib/domains/recorder/data/services/path_helper.dart` | `other_application_source` | medium | None | None | accept |
| R097 | `lib/domains/recorder/data/services/recorder_background_service.dart` | `other_application_source` | medium | None | None | accept |
| R086 | `lib/domains/recorder/data/services/recorder_continuation_policy.dart` | `other_application_source` | medium | None | None | accept |
| R100 | `lib/domains/recorder/data/services/recorder_diagnostics.dart` | `other_application_source` | medium | None | None | accept |
| A | `lib/domains/recorder/data/services/recording_bitrate_window.dart` | `other_application_source` | medium | 27 | 0 | accept |
| A | `lib/domains/recorder/data/services/recording_danmaku_service.dart` | `other_application_source` | medium | 241 | 0 | accept |
| R099 | `lib/domains/recorder/data/services/recording_output_metrics.dart` | `other_application_source` | medium | None | None | accept |
| R100 | `lib/domains/recorder/data/services/recording_segment_clock.dart` | `other_application_source` | medium | None | None | accept |
| R088 | `lib/domains/recorder/data/services/stream_resolver_service.dart` | `other_application_source` | medium | None | None | accept |
| R092 | `lib/domains/recorder/data/services/video_processor_service.dart` | `other_application_source` | medium | None | None | accept |
| R092 | `lib/domains/recorder/domain/models/live_record_task.dart` | `other_application_source` | medium | None | None | accept |
| R083 | `lib/domains/recorder/domain/models/record_file_item.dart` | `other_application_source` | medium | None | None | accept |
| R078 | `lib/domains/recorder/domain/models/record_status.dart` | `other_application_source` | medium | None | None | accept |
| R090 | `lib/domains/recorder/domain/models/recorder_task_ordering.dart` | `other_application_source` | medium | None | None | accept |
| A | `lib/domains/recorder/presentation/pages/local_player/local_video_player_controller.dart` | `other_application_source` | medium | 884 | 0 | accept |
| A | `lib/domains/recorder/presentation/pages/local_player/local_video_player_page.dart` | `other_application_source` | medium | 2196 | 0 | accept |
| A | `lib/domains/recorder/presentation/pages/local_player/recording_danmaku_track.dart` | `other_application_source` | medium | 259 | 0 | accept |
| A | `lib/domains/recorder/presentation/pages/local_player/recording_resume.dart` | `other_application_source` | medium | 29 | 0 | accept |
| R097 | `lib/domains/recorder/presentation/pages/record_settings/record_settings_page.dart` | `other_application_source` | medium | None | None | accept |
| R090 | `lib/domains/recorder/presentation/pages/recorder/recorder_controller.dart` | `other_application_source` | medium | None | None | accept |
| R087 | `lib/domains/recorder/presentation/pages/recorder/recorder_page.dart` | `other_application_source` | medium | None | None | accept |
| R090 | `lib/domains/recorder/presentation/widgets/record_action_button.dart` | `other_application_source` | medium | None | None | accept |
| R100 | `lib/domains/recorder/presentation/widgets/record_action_content.dart` | `other_application_source` | medium | None | None | accept |
| R098 | `lib/domains/recorder/presentation/widgets/recorder_bounded_scroll.dart` | `other_application_source` | medium | None | None | accept |
| A | `lib/domains/wallpaper/data/itab_client.dart` | `other_application_source` | medium | 69 | 0 | accept |
| A | `lib/domains/wallpaper/data/local_wallpapers.dart` | `other_application_source` | medium | 103 | 0 | accept |
| A | `lib/domains/wallpaper/data/wallpaper_api_client.dart` | `other_application_source` | medium | 94 | 0 | accept |
| A | `lib/domains/wallpaper/data/wallpaper_media_store.dart` | `other_application_source` | medium | 154 | 0 | accept |
| A | `lib/domains/wallpaper/data/wallpaper_presets.dart` | `other_application_source` | medium | 221 | 0 | accept |
| A | `lib/domains/wallpaper/data/wallpaper_repository.dart` | `other_application_source` | medium | 127 | 0 | accept |
| A | `lib/domains/wallpaper/domain/background_controller.dart` | `other_application_source` | medium | 370 | 0 | accept |
| A | `lib/domains/wallpaper/domain/wallpaper_api_catalog.dart` | `other_application_source` | medium | 386 | 0 | accept |
| A | `lib/domains/wallpaper/domain/wallpaper_catalog.dart` | `other_application_source` | medium | 241 | 0 | accept |
| A | `lib/domains/wallpaper/presentation/app_background.dart` | `other_application_source` | medium | 337 | 0 | accept |
| A | `lib/domains/wallpaper/presentation/wallpaper_api_group_page.dart` | `other_application_source` | medium | 48 | 0 | accept |
| A | `lib/domains/wallpaper/presentation/wallpaper_api_page.dart` | `other_application_source` | medium | 36 | 0 | accept |
| A | `lib/domains/wallpaper/presentation/wallpaper_display_options.dart` | `other_application_source` | medium | 89 | 0 | accept |
| A | `lib/domains/wallpaper/presentation/wallpaper_gallery_page.dart` | `other_application_source` | medium | 48 | 0 | accept |
| A | `lib/domains/wallpaper/presentation/wallpaper_grid_controller.dart` | `other_application_source` | medium | 60 | 0 | accept |
| A | `lib/domains/wallpaper/presentation/wallpaper_image.dart` | `other_application_source` | medium | 92 | 0 | accept |
| A | `lib/domains/wallpaper/presentation/wallpaper_items_page.dart` | `other_application_source` | medium | 150 | 0 | accept |
| A | `lib/domains/wallpaper/presentation/wallpaper_library_page.dart` | `other_application_source` | medium | 60 | 0 | accept |
| A | `lib/domains/wallpaper/presentation/wallpaper_page.dart` | `other_application_source` | medium | 278 | 0 | accept |
| A | `lib/domains/wallpaper/presentation/wallpaper_preview_page.dart` | `other_application_source` | medium | 650 | 0 | accept |
| A | `lib/domains/wallpaper/presentation/wallpaper_tile.dart` | `other_application_source` | medium | 134 | 0 | accept |
| R095 | `lib/features/about/about_page.dart` | `other_application_source` | medium | None | None | accept |
| R098 | `lib/features/about/version_history.dart` | `other_application_source` | medium | None | None | accept |
| R072 | `lib/features/about/widgets/release_history_repository.dart` | `other_application_source` | medium | None | None | accept |
| R098 | `lib/features/about/widgets/version_dialog.dart` | `other_application_source` | medium | None | None | accept |
| R076 | `lib/features/backup/backup_controller.dart` | `other_application_source` | medium | None | None | accept |
| R084 | `lib/features/backup/backup_page.dart` | `other_application_source` | medium | None | None | accept |
| R052 | `lib/features/backup/backup_recovery_service.dart` | `other_application_source` | medium | None | None | accept |
| A | `lib/features/backup/backup_section_picker.dart` | `other_application_source` | medium | 113 | 0 | accept |
| R090 | `lib/features/backup/scan_page.dart` | `other_application_source` | medium | None | None | accept |
| R085 | `lib/features/home/home_page.dart` | `other_application_source` | medium | None | None | accept |
| R096 | `lib/features/home/mobile_view.dart` | `other_application_source` | medium | None | None | accept |
| R097 | `lib/features/home/tablet_view.dart` | `other_application_source` | medium | None | None | accept |
| R100 | `lib/features/remote_receiver/remote_sync_device.dart` | `other_application_source` | medium | None | None | accept |
| R073 | `lib/features/remote_receiver/remote_sync_page.dart` | `other_application_source` | medium | None | None | accept |
| R050 | `lib/features/remote_receiver/remote_sync_protocol.dart` | `other_application_source` | medium | None | None | accept |
| R090 | `lib/features/remote_receiver/remote_sync_service.dart` | `other_application_source` | medium | None | None | accept |
| R094 | `lib/features/settings/pages/audience_metric_settings_page.dart` | `other_application_source` | medium | None | None | accept |
| R098 | `lib/features/settings/pages/cache_data_settings_page.dart` | `other_application_source` | medium | None | None | accept |
| R098 | `lib/features/settings/pages/font_family_manager_page.dart` | `other_application_source` | medium | None | None | accept |
| R098 | `lib/features/settings/pages/font_settings_page.dart` | `other_application_source` | medium | None | None | accept |
| R099 | `lib/features/settings/pages/general_settings_page.dart` | `other_application_source` | medium | None | None | accept |
| R097 | `lib/features/settings/pages/loading_style_settings_page.dart` | `other_application_source` | medium | None | None | accept |
| R098 | `lib/features/settings/pages/local_config_preview_page.dart` | `other_application_source` | medium | None | None | accept |
| R097 | `lib/features/settings/pages/local_interaction_settings_page.dart` | `other_application_source` | medium | None | None | accept |
| A | `lib/features/settings/pages/mpv_option_page.dart` | `other_application_source` | medium | 57 | 0 | accept |
| R092 | `lib/features/settings/pages/navigation_settings_page.dart` | `other_application_source` | medium | None | None | accept |
| R098 | `lib/features/settings/pages/network_proxy_settings_page.dart` | `other_application_source` | medium | None | None | accept |
| R098 | `lib/features/settings/pages/page_settings_page.dart` | `other_application_source` | medium | None | None | accept |
| R092 | `lib/features/settings/pages/platform_settings_page.dart` | `other_application_source` | medium | None | None | accept |
| A | `lib/features/settings/pages/player_guide_page.dart` | `other_application_source` | medium | 260 | 0 | accept |
| A | `lib/features/settings/pages/player_kernel_settings_page.dart` | `other_application_source` | medium | 522 | 0 | accept |
| A | `lib/features/settings/pages/player_preset_page.dart` | `other_application_source` | medium | 51 | 0 | accept |
| A | `lib/features/settings/pages/player_super_resolution_page.dart` | `other_application_source` | medium | 50 | 0 | accept |
| R098 | `lib/features/settings/pages/portrait_live_settings_page.dart` | `other_application_source` | medium | None | None | accept |
| R095 | `lib/features/settings/pages/refresh_settings_page.dart` | `other_application_source` | medium | None | None | accept |
| R098 | `lib/features/settings/pages/room_card_settings_page.dart` | `other_application_source` | medium | None | None | accept |
| R094 | `lib/features/settings/pages/theme_settings_page.dart` | `other_application_source` | medium | None | None | accept |
| R087 | `lib/features/settings/pages/video_settings_page.dart` | `other_application_source` | medium | None | None | accept |
| R082 | `lib/features/settings/settings_page.dart` | `other_application_source` | medium | None | None | accept |
| R100 | `lib/features/settings/widgets/app_color_picker_dialog.dart` | `other_application_source` | medium | None | None | accept |
| R095 | `lib/features/splash/splash_screen.dart` | `other_application_source` | medium | None | None | accept |
| R091 | `lib/features/toolbox/toolbox_controller.dart` | `other_application_source` | medium | None | None | accept |
| R095 | `lib/features/toolbox/toolbox_page.dart` | `other_application_source` | medium | None | None | accept |
| R085 | `lib/features/version/app_update_flow.dart` | `other_application_source` | medium | None | None | accept |
| R089 | `lib/features/version/version_controller.dart` | `other_application_source` | medium | None | None | accept |
| R094 | `lib/features/version/version_page.dart` | `other_application_source` | medium | None | None | accept |
| R097 | `lib/features/web_dav/web_dav_config.dart` | `other_application_source` | medium | None | None | accept |
| R086 | `lib/features/web_dav/web_dav_controller.dart` | `other_application_source` | medium | None | None | accept |
| R099 | `lib/features/web_dav/web_dav_help.dart` | `other_application_source` | medium | None | None | accept |
| R091 | `lib/features/web_dav/web_dav_page.dart` | `other_application_source` | medium | None | None | accept |
| R100 | `lib/features/web_dav/web_dav_service.dart` | `other_application_source` | medium | None | None | accept |
| R092 | `lib/features/web_dav/web_dav_settings_controller.dart` | `other_application_source` | medium | None | None | accept |
| M | `lib/gen/env.g.dart` | `other_application_source` | medium | 10 | 1 | accept |
| M | `lib/get/get_instance/src/extension_instance.dart` | `other_application_source` | medium | 0 | 1 | accept |
| M | `lib/get/get_navigation/src/extension_navigation.dart` | `other_application_source` | medium | 1 | 2 | accept |
| M | `lib/get/get_navigation/src/root/get_material_app.dart` | `other_application_source` | medium | 0 | 6 | accept |
| M | `lib/get/get_navigation/src/root/get_root.dart` | `other_application_source` | medium | 7 | 0 | accept |
| M | `lib/get/get_navigation/src/routes/observers/route_observer.dart` | `other_application_source` | medium | 0 | 1 | accept |
| M | `lib/get/get_navigation/src/snackbar/snackbar.dart` | `other_application_source` | medium | 1 | 1 | accept |
| M | `lib/get/get_rx/src/rx_types/rx_core/rx_impl.dart` | `other_application_source` | medium | 0 | 1 | accept |
| M | `lib/get/get_rx/src/rx_workers/rx_workers.dart` | `other_application_source` | medium | 0 | 1 | accept |
| M | `lib/get/get_state_manager/src/rx_flutter/rx_notifier.dart` | `other_application_source` | medium | 0 | 3 | accept |
| M | `lib/get/get_utils/src/extensions/num_extensions.dart` | `other_application_source` | medium | 0 | 1 | accept |
| M | `lib/main.dart` | `navigation_and_startup` | high | 58 | 19 | accept |
| D | `lib/model/tars/get_cdn_token_ex_req.dart` | `other_application_source` | medium | 0 | 52 | accept |
| D | `lib/model/tars/get_cdn_token_ex_resp.dart` | `other_application_source` | medium | 0 | 35 | accept |
| D | `lib/model/tars/get_cdn_token_req.dart` | `other_application_source` | medium | 0 | 48 | accept |
| D | `lib/model/tars/get_cdn_token_resp.dart` | `other_application_source` | medium | 0 | 87 | accept |
| D | `lib/model/tars/huya_danmaku.dart` | `other_application_source` | medium | 0 | 121 | accept |
| D | `lib/model/tars/types.dart` | `other_application_source` | medium | 0 | 136 | accept |
| D | `lib/modules/account/account_bing.dart` | `app_modules` | medium | 0 | 9 | accept |
| D | `lib/modules/account/douyin/douyin_cookie_binding.dart` | `app_modules` | medium | 0 | 9 | accept |
| D | `lib/modules/account/douyu/douyu_cookie_binding.dart` | `app_modules` | medium | 0 | 7 | accept |
| D | `lib/modules/account/douyu/douyu_cookie_controller.dart` | `app_modules` | medium | 0 | 24 | accept |
| D | `lib/modules/account/douyu/douyu_cookie_page.dart` | `app_modules` | medium | 0 | 15 | accept |
| D | `lib/modules/account/huya/huya_cookie_binding.dart` | `app_modules` | medium | 0 | 9 | accept |
| D | `lib/modules/account/kuaishou/kuaishou_cookie_binding.dart` | `app_modules` | medium | 0 | 9 | accept |
| D | `lib/modules/account/soop/soop_cookie_binding.dart` | `app_modules` | medium | 0 | 9 | accept |
| D | `lib/modules/account/taobao/taobao_cookie_binding.dart` | `app_modules` | medium | 0 | 7 | accept |
| D | `lib/modules/account/taobao/taobao_cookie_controller.dart` | `app_modules` | medium | 0 | 24 | accept |
| D | `lib/modules/account/taobao/taobao_cookie_page.dart` | `app_modules` | medium | 0 | 15 | accept |
| D | `lib/modules/account/twitch/twitch_cookie_binding.dart` | `app_modules` | medium | 0 | 9 | accept |
| D | `lib/modules/account/yy/yy_cookie_binding.dart` | `app_modules` | medium | 0 | 9 | accept |
| D | `lib/modules/area_rooms/area_rooms_binding.dart` | `app_modules` | medium | 0 | 44 | accept |
| D | `lib/modules/areas/favorite_areas_binding.dart` | `app_modules` | medium | 0 | 9 | accept |
| D | `lib/modules/hot_areas/hot_areas_binding.dart` | `app_modules` | medium | 0 | 9 | accept |
| D | `lib/modules/live_play/bindings/live_play_binding.dart` | `live_playback` | high | 0 | 9 | accept |
| D | `lib/modules/live_play/controllers/danmaku_message_gate.dart` | `live_playback` | high | 0 | 65 | accept |
| D | `lib/modules/live_play/controllers/danmaku_session_host.dart` | `live_playback` | high | 0 | 23 | accept |
| D | `lib/modules/live_play/controllers/danmaku_similarity_filter.dart` | `live_playback` | high | 0 | 162 | accept |
| D | `lib/modules/live_play/controllers/player_state.dart` | `live_playback` | high | 0 | 18 | accept |
| D | `lib/modules/live_play/controllers/repeated_danmaku_filter.dart` | `live_playback` | high | 0 | 45 | accept |
| D | `lib/modules/live_play/services/room_external_opener.dart` | `live_playback` | high | 0 | 302 | accept |
| D | `lib/modules/live_play/states/load_type.dart` | `live_playback` | high | 0 | 1 | accept |
| D | `lib/modules/live_play/widgets/danmaku/compact_danmaku_overlay.dart` | `live_playback` | high | 0 | 94 | accept |
| D | `lib/modules/live_play/widgets/danmaku/danmaku_settings_binding.dart` | `live_playback` | high | 0 | 30 | accept |
| D | `lib/modules/live_play/widgets/keyboard/video_keyboard.dart` | `live_playback` | high | 0 | 101 | accept |
| D | `lib/modules/live_play/widgets/layout/live_play_back_scope.dart` | `live_playback` | high | 0 | 130 | accept |
| D | `lib/modules/live_play/widgets/layout/live_play_video.dart` | `live_playback` | high | 0 | 77 | accept |
| D | `lib/modules/multiview/bindings/multiview_binding.dart` | `app_modules` | medium | 0 | 13 | accept |
| D | `lib/modules/multiview/cells/multiview_cell_player.dart` | `app_modules` | medium | 0 | 425 | accept |
| D | `lib/modules/multiview/cells/multiview_frame_watchdog.dart` | `app_modules` | medium | 0 | 110 | accept |
| D | `lib/modules/multiview/danmaku/multiview_danmaku_settings_binding.dart` | `app_modules` | medium | 0 | 48 | accept |
| D | `lib/modules/multiview/multiview_controller.dart` | `app_modules` | medium | 0 | 1301 | accept |
| D | `lib/modules/remote_receiver/local_address.dart` | `app_modules` | medium | 0 | 10 | accept |
| D | `lib/modules/remote_receiver/remote_sync_binding.dart` | `app_modules` | medium | 0 | 9 | accept |
| D | `lib/modules/search/search_binding.dart` | `app_modules` | medium | 0 | 9 | accept |
| D | `lib/modules/search/web_search_binding.dart` | `app_modules` | medium | 0 | 9 | accept |
| D | `lib/modules/settings/pages/audio_output_settings_page.dart` | `app_modules` | medium | 0 | 75 | accept |
| D | `lib/modules/settings/pages/decoder_settings.dart` | `app_modules` | medium | 0 | 70 | accept |
| D | `lib/modules/settings/pages/pip_danmaku_settings_page.dart` | `app_modules` | medium | 0 | 744 | accept |
| D | `lib/modules/settings/pages/player_kernel_settings_page.dart` | `app_modules` | medium | 0 | 468 | accept |
| D | `lib/modules/settings/pages/renderer_settings.dart` | `app_modules` | medium | 0 | 75 | accept |
| D | `lib/modules/settings/settings_binding.dart` | `app_modules` | medium | 0 | 8 | accept |
| D | `lib/modules/shield/danmu_shield_binding.dart` | `app_modules` | medium | 0 | 9 | accept |
| D | `lib/modules/tags/tag_management_binding.dart` | `app_modules` | medium | 0 | 9 | accept |
| D | `lib/modules/toolbox/boolbox_binding.dart` | `app_modules` | medium | 0 | 9 | accept |
| D | `lib/modules/version/version_binding.dart` | `app_modules` | medium | 0 | 9 | accept |
| D | `lib/modules/web_dav/web_dav_binding.dart` | `app_modules` | medium | 0 | 9 | accept |
| D | `lib/pkg/tars/codec/tars_decode_exception.dart` | `other_application_source` | medium | 0 | 8 | accept |
| D | `lib/pkg/tars/codec/tars_encode_exception.dart` | `other_application_source` | medium | 0 | 9 | accept |
| D | `lib/player/adapters/fijk_adapter.dart` | `live_playback` | high | 0 | 428 | accept |
| D | `lib/player/adapters/media_kit_adapter.dart` | `live_playback` | high | 0 | 1258 | accept |
| D | `lib/player/adapters/player_adapter_factory.dart` | `live_playback` | high | 0 | 20 | accept |
| D | `lib/player/adapters/video_player_adapter.dart` | `live_playback` | high | 0 | 341 | accept |
| D | `lib/player/core/bigo_playback_input.dart` | `live_playback` | high | 0 | 45 | accept |
| D | `lib/player/core/engine_fallback_manager.dart` | `live_playback` | high | 0 | 73 | accept |
| D | `lib/player/core/fc2_playback_input.dart` | `live_playback` | high | 0 | 50 | accept |
| D | `lib/player/core/line_fallback_manager.dart` | `live_playback` | high | 0 | 38 | accept |
| D | `lib/player/core/live_audio_handler.dart` | `live_playback` | high | 0 | 310 | accept |
| D | `lib/player/core/live_audio_service.dart` | `live_playback` | high | 0 | 262 | accept |
| D | `lib/player/core/live_input_playback_binding.dart` | `live_playback` | high | 0 | 24 | accept |
| D | `lib/player/core/live_stream_geometry_hint.dart` | `live_playback` | high | 0 | 345 | accept |
| D | `lib/player/core/niconico_playback_input.dart` | `live_playback` | high | 0 | 76 | accept |
| D | `lib/player/core/playback_source_transport.dart` | `live_playback` | high | 0 | 246 | accept |
| D | `lib/player/core/player_error_classifier.dart` | `live_playback` | high | 0 | 188 | accept |
| D | `lib/player/core/player_manager.dart` | `live_playback` | high | 0 | 4949 | accept |
| D | `lib/player/core/portrait_stream_support.dart` | `live_playback` | high | 0 | 830 | accept |
| D | `lib/player/core/source_event_fence.dart` | `live_playback` | high | 0 | 83 | accept |
| D | `lib/player/global_player_service.dart` | `live_playback` | high | 0 | 96 | accept |
| D | `lib/player/interface/fijk_player_accessor.dart` | `live_playback` | high | 0 | 5 | accept |
| D | `lib/player/interface/unified_player_interface.dart` | `live_playback` | high | 0 | 140 | accept |
| D | `lib/player/interface/video_player_accessor.dart` | `live_playback` | high | 0 | 5 | accept |
| D | `lib/player/models/player_error_type.dart` | `live_playback` | high | 0 | 1 | accept |
| D | `lib/player/models/player_exception.dart` | `live_playback` | high | 0 | 22 | accept |
| D | `lib/player/models/player_state.dart` | `live_playback` | high | 0 | 14 | accept |
| D | `lib/player/utils/fijk_helper.dart` | `live_playback` | high | 0 | 74 | accept |
| D | `lib/player/utils/fullscreen.dart` | `live_playback` | high | 0 | 336 | accept |
| D | `lib/player/utils/live_buffer_policy.dart` | `live_playback` | high | 0 | 25 | accept |
| D | `lib/player/utils/mpv_platform_profile.dart` | `live_playback` | high | 0 | 96 | accept |
| D | `lib/player/utils/player_consts.dart` | `live_playback` | high | 0 | 209 | accept |
| D | `lib/player/utils/window_helper.dart` | `live_playback` | high | 0 | 490 | accept |
| D | `lib/plugins/utils.dart` | `other_application_source` | medium | 0 | 652 | accept |
| D | `lib/recorder/pages/record_settings/record_settings_binding.dart` | `recording_and_storage` | high | 0 | 9 | accept |
| D | `lib/recorder/pages/recorder/recorder_binding.dart` | `recording_and_storage` | high | 0 | 9 | accept |
| D | `lib/recorder/services/hls_session_cookies.dart` | `recording_and_storage` | high | 0 | 2 | accept |
| D | `lib/recorder/services/recorder_proxy_routing.dart` | `recording_and_storage` | high | 0 | 11 | accept |
| R089 | `lib/shared/platforms/acfun/acfun_api.dart` | `other_application_source` | medium | None | None | accept |
| A | `lib/shared/platforms/acfun/acfun_danmaku.dart` | `other_application_source` | medium | 29 | 0 | accept |
| R100 | `lib/shared/platforms/acfun/acfun_directory.dart` | `other_application_source` | medium | None | None | accept |
| A | `lib/shared/platforms/acfun/acfun_link_danmaku.dart` | `other_application_source` | medium | 540 | 0 | accept |
| A | `lib/shared/platforms/acfun/acfun_protobuf.dart` | `other_application_source` | medium | 158 | 0 | accept |
| R098 | `lib/shared/platforms/acfun/acfun_search.dart` | `other_application_source` | medium | None | None | accept |
| R058 | `lib/shared/platforms/acfun/acfun_site.dart` | `other_application_source` | medium | None | None | accept |
| R089 | `lib/shared/platforms/baidulive/baidu_live_api.dart` | `other_application_source` | medium | None | None | accept |
| A | `lib/shared/platforms/baidulive/baidu_live_danmaku.dart` | `other_application_source` | medium | 323 | 0 | accept |
| R085 | `lib/shared/platforms/baidulive/baidu_live_link.dart` | `other_application_source` | medium | None | None | accept |
| R071 | `lib/shared/platforms/baidulive/baidu_live_site.dart` | `other_application_source` | medium | None | None | accept |
| R087 | `lib/shared/platforms/bigo/bigo_api.dart` | `other_application_source` | medium | None | None | accept |
| A | `lib/shared/platforms/bigo/bigo_danmaku.dart` | `other_application_source` | medium | 310 | 0 | accept |
| R100 | `lib/shared/platforms/bigo/bigo_hls_protection.dart` | `other_application_source` | medium | None | None | accept |
| R078 | `lib/shared/platforms/bigo/bigo_input_recipe.dart` | `other_application_source` | medium | None | None | accept |
| R100 | `lib/shared/platforms/bigo/bigo_link.dart` | `other_application_source` | medium | None | None | accept |
| R071 | `lib/shared/platforms/bigo/bigo_site.dart` | `other_application_source` | medium | None | None | accept |
| R100 | `lib/shared/platforms/bigo/bigo_token.dart` | `other_application_source` | medium | None | None | accept |
| R065 | `lib/shared/platforms/bilibili/bilibili_danmaku.dart` | `other_application_source` | medium | None | None | accept |
| A | `lib/shared/platforms/bilibili/bilibili_danmaku_capability.dart` | `other_application_source` | medium | 22 | 0 | accept |
| R075 | `lib/shared/platforms/bilibili/bilibili_site.dart` | `other_application_source` | medium | None | None | accept |
| R097 | `lib/shared/platforms/cc/cc_catalog.dart` | `other_application_source` | medium | None | None | accept |
| A | `lib/shared/platforms/cc/cc_danmaku_capability.dart` | `other_application_source` | medium | 6 | 0 | accept |
| R071 | `lib/shared/platforms/cc/cc_site.dart` | `other_application_source` | medium | None | None | accept |
| R092 | `lib/shared/platforms/chzzk/chzzk_api.dart` | `other_application_source` | medium | None | None | accept |
| A | `lib/shared/platforms/chzzk/chzzk_danmaku.dart` | `other_application_source` | medium | 247 | 0 | accept |
| R055 | `lib/shared/platforms/chzzk/chzzk_link.dart` | `other_application_source` | medium | None | None | accept |
| R073 | `lib/shared/platforms/chzzk/chzzk_site.dart` | `other_application_source` | medium | None | None | accept |
| A | `lib/shared/platforms/current_live_room.dart` | `other_application_source` | medium | 7 | 0 | accept |
| A | `lib/shared/platforms/danmaku_emoji.dart` | `other_application_source` | medium | 48 | 0 | accept |
| R094 | `lib/shared/platforms/douyin/abogus.dart` | `other_application_source` | medium | None | None | accept |
| R100 | `lib/shared/platforms/douyin/douyin_audience.dart` | `other_application_source` | medium | None | None | accept |
| R089 | `lib/shared/platforms/douyin/douyin_danmaku.dart` | `other_application_source` | medium | None | None | accept |
| A | `lib/shared/platforms/douyin/douyin_danmaku_capability.dart` | `other_application_source` | medium | 16 | 0 | accept |
| R097 | `lib/shared/platforms/douyin/douyin_request_params.dart` | `other_application_source` | medium | None | None | accept |
| R096 | `lib/shared/platforms/douyin/douyin_search.dart` | `other_application_source` | medium | None | None | accept |
| R081 | `lib/shared/platforms/douyin/douyin_site.dart` | `other_application_source` | medium | None | None | accept |
| R087 | `lib/shared/platforms/douyin/douyin_utils.dart` | `other_application_source` | medium | None | None | accept |
| R066 | `lib/shared/platforms/douyin/douyin_xbogus.dart` | `other_application_source` | medium | None | None | accept |
| R099 | `lib/shared/platforms/douyin/proto/douyin.pb.dart` | `other_application_source` | medium | None | None | accept |
| R099 | `lib/shared/platforms/douyin/proto/douyin.pbenum.dart` | `other_application_source` | medium | None | None | accept |
| R099 | `lib/shared/platforms/douyin/proto/douyin.pbjson.dart` | `other_application_source` | medium | None | None | accept |
| R100 | `lib/shared/platforms/douyin/proto/douyin.proto` | `other_application_source` | medium | None | None | accept |
| A | `lib/shared/platforms/douyu/douyu_danmaku.dart` | `other_application_source` | medium | 292 | 0 | accept |
| A | `lib/shared/platforms/douyu/douyu_danmaku_capability.dart` | `other_application_source` | medium | 15 | 0 | accept |
| R072 | `lib/shared/platforms/douyu/douyu_site.dart` | `other_application_source` | medium | None | None | accept |
| R087 | `lib/shared/platforms/emoji_manager.dart` | `other_application_source` | medium | None | None | accept |
| R082 | `lib/shared/platforms/empty_danmaku.dart` | `other_application_source` | medium | None | None | accept |
| R089 | `lib/shared/platforms/fc2live/fc2_api.dart` | `other_application_source` | medium | None | None | accept |
| R098 | `lib/shared/platforms/fc2live/fc2_control_session.dart` | `other_application_source` | medium | None | None | accept |
| R079 | `lib/shared/platforms/fc2live/fc2_input_recipe.dart` | `other_application_source` | medium | None | None | accept |
| R100 | `lib/shared/platforms/fc2live/fc2_link.dart` | `other_application_source` | medium | None | None | accept |
| A | `lib/shared/platforms/fc2live/fc2_live_danmaku.dart` | `other_application_source` | medium | 317 | 0 | accept |
| R071 | `lib/shared/platforms/fc2live/fc2_site.dart` | `other_application_source` | medium | None | None | accept |
| R083 | `lib/shared/platforms/huya/huya_danmaku.dart` | `other_application_source` | medium | None | None | accept |
| A | `lib/shared/platforms/huya/huya_danmaku_capability.dart` | `other_application_source` | medium | 19 | 0 | accept |
| A | `lib/shared/platforms/huya/huya_request_params.dart` | `other_application_source` | medium | 53 | 0 | accept |
| R073 | `lib/shared/platforms/huya/huya_site.dart` | `other_application_source` | medium | None | None | accept |
| R100 | `lib/shared/platforms/huya/huya_transport_policy.dart` | `other_application_source` | medium | None | None | accept |
| R063 | `lib/shared/platforms/huya/huya_utils.dart` | `other_application_source` | medium | None | None | accept |
| A | `lib/shared/platforms/huya/huya_vip_room_id.dart` | `other_application_source` | medium | 75 | 0 | accept |
| R093 | `lib/shared/platforms/inke/inke_api.dart` | `other_application_source` | medium | None | None | accept |
| R063 | `lib/shared/platforms/inke/inke_site.dart` | `other_application_source` | medium | None | None | accept |
| R092 | `lib/shared/platforms/jdlive/jd_live_api.dart` | `other_application_source` | medium | None | None | accept |
| A | `lib/shared/platforms/jdlive/jd_live_danmaku.dart` | `other_application_source` | medium | 305 | 0 | accept |
| R100 | `lib/shared/platforms/jdlive/jd_live_link.dart` | `other_application_source` | medium | None | None | accept |
| R069 | `lib/shared/platforms/jdlive/jd_live_site.dart` | `other_application_source` | medium | None | None | accept |
| R098 | `lib/shared/platforms/kilakila/kilakila_api.dart` | `other_application_source` | medium | None | None | accept |
| A | `lib/shared/platforms/kilakila/kilakila_danmaku.dart` | `other_application_source` | medium | 252 | 0 | accept |
| R100 | `lib/shared/platforms/kilakila/kilakila_link.dart` | `other_application_source` | medium | None | None | accept |
| R071 | `lib/shared/platforms/kilakila/kilakila_site.dart` | `other_application_source` | medium | None | None | accept |
| R094 | `lib/shared/platforms/kuaishou/kuaishou_danmaku.dart` | `other_application_source` | medium | None | None | accept |
| R064 | `lib/shared/platforms/kuaishou/kuaishou_site.dart` | `other_application_source` | medium | None | None | accept |
| R097 | `lib/shared/platforms/kugoulive/kugou_live_api.dart` | `other_application_source` | medium | None | None | accept |
| A | `lib/shared/platforms/kugoulive/kugou_live_danmaku.dart` | `other_application_source` | medium | 5 | 0 | accept |
| R100 | `lib/shared/platforms/kugoulive/kugou_live_link.dart` | `other_application_source` | medium | None | None | accept |
| A | `lib/shared/platforms/kugoulive/kugou_live_link_danmaku.dart` | `other_application_source` | medium | 633 | 0 | accept |
| R071 | `lib/shared/platforms/kugoulive/kugou_live_site.dart` | `other_application_source` | medium | None | None | accept |
| R092 | `lib/shared/platforms/live_danmaku.dart` | `other_application_source` | medium | None | None | accept |
| A | `lib/shared/platforms/live_danmaku_capability.dart` | `other_application_source` | medium | 20 | 0 | accept |
| R093 | `lib/shared/platforms/live_directory.dart` | `other_application_source` | medium | None | None | accept |
| A | `lib/shared/platforms/live_external_room.dart` | `other_application_source` | medium | 28 | 0 | accept |
| R100 | `lib/shared/platforms/live_input_recipe.dart` | `other_application_source` | medium | None | None | accept |
| R081 | `lib/shared/platforms/live_quality_discovery.dart` | `other_application_source` | medium | None | None | accept |
| R091 | `lib/shared/platforms/live_search.dart` | `other_application_source` | medium | None | None | accept |
| R100 | `lib/shared/platforms/live_short_link_session.dart` | `other_application_source` | medium | None | None | accept |
| R066 | `lib/shared/platforms/live_site.dart` | `other_application_source` | medium | None | None | accept |
| R090 | `lib/shared/platforms/liveme/liveme_api.dart` | `other_application_source` | medium | None | None | accept |
| R100 | `lib/shared/platforms/liveme/liveme_link.dart` | `other_application_source` | medium | None | None | accept |
| R100 | `lib/shared/platforms/liveme/liveme_signer.dart` | `other_application_source` | medium | None | None | accept |
| R066 | `lib/shared/platforms/liveme/liveme_site.dart` | `other_application_source` | medium | None | None | accept |
| R090 | `lib/shared/platforms/looklive/look_live_api.dart` | `other_application_source` | medium | None | None | accept |
| A | `lib/shared/platforms/looklive/look_live_danmaku.dart` | `other_application_source` | medium | 7 | 0 | accept |
| R100 | `lib/shared/platforms/looklive/look_live_link.dart` | `other_application_source` | medium | None | None | accept |
| A | `lib/shared/platforms/looklive/look_live_link_danmaku.dart` | `other_application_source` | medium | 469 | 0 | accept |
| R070 | `lib/shared/platforms/looklive/look_live_site.dart` | `other_application_source` | medium | None | None | accept |
| R093 | `lib/shared/platforms/missevan/missevan_api.dart` | `other_application_source` | medium | None | None | accept |
| A | `lib/shared/platforms/missevan/missevan_danmaku.dart` | `other_application_source` | medium | 300 | 0 | accept |
| R065 | `lib/shared/platforms/missevan/missevan_site.dart` | `other_application_source` | medium | None | None | accept |
| R073 | `lib/shared/platforms/niconico/niconico_api.dart` | `other_application_source` | medium | None | None | accept |
| A | `lib/shared/platforms/niconico/niconico_contract.dart` | `other_application_source` | medium | 20 | 0 | accept |
| R086 | `lib/shared/platforms/niconico/niconico_directory.dart` | `other_application_source` | medium | None | None | accept |
| R090 | `lib/shared/platforms/niconico/niconico_input_recipe.dart` | `other_application_source` | medium | None | None | accept |
| A | `lib/shared/platforms/niconico/niconico_link.dart` | `other_application_source` | medium | 43 | 0 | accept |
| R094 | `lib/shared/platforms/niconico/niconico_quality_catalog.dart` | `other_application_source` | medium | None | None | accept |
| R097 | `lib/shared/platforms/niconico/niconico_session.dart` | `other_application_source` | medium | None | None | accept |
| R061 | `lib/shared/platforms/niconico/niconico_site.dart` | `other_application_source` | medium | None | None | accept |
| R096 | `lib/shared/platforms/niconico/niconico_stream.dart` | `other_application_source` | medium | None | None | accept |
| R097 | `lib/shared/platforms/niconico/niconico_watch.dart` | `other_application_source` | medium | None | None | accept |
| R095 | `lib/shared/platforms/pandalive/pandalive_api.dart` | `other_application_source` | medium | None | None | accept |
| A | `lib/shared/platforms/pandalive/pandalive_danmaku.dart` | `other_application_source` | medium | 208 | 0 | accept |
| R100 | `lib/shared/platforms/pandalive/pandalive_link.dart` | `other_application_source` | medium | None | None | accept |
| R068 | `lib/shared/platforms/pandalive/pandalive_site.dart` | `other_application_source` | medium | None | None | accept |
| R092 | `lib/shared/platforms/picarto/picarto_api.dart` | `other_application_source` | medium | None | None | accept |
| A | `lib/shared/platforms/picarto/picarto_danmaku.dart` | `other_application_source` | medium | 339 | 0 | accept |
| R098 | `lib/shared/platforms/picarto/picarto_hls.dart` | `other_application_source` | medium | None | None | accept |
| R059 | `lib/shared/platforms/picarto/picarto_site.dart` | `other_application_source` | medium | None | None | accept |
| R091 | `lib/shared/platforms/seventeenlive/seventeenlive_api.dart` | `other_application_source` | medium | None | None | accept |
| A | `lib/shared/platforms/seventeenlive/seventeenlive_danmaku.dart` | `other_application_source` | medium | 318 | 0 | accept |
| R093 | `lib/shared/platforms/seventeenlive/seventeenlive_link.dart` | `other_application_source` | medium | None | None | accept |
| R065 | `lib/shared/platforms/seventeenlive/seventeenlive_site.dart` | `other_application_source` | medium | None | None | accept |
| R082 | `lib/shared/platforms/showroom/showroom_api.dart` | `other_application_source` | medium | None | None | accept |
| A | `lib/shared/platforms/showroom/showroom_danmaku.dart` | `other_application_source` | medium | 148 | 0 | accept |
| R100 | `lib/shared/platforms/showroom/showroom_link.dart` | `other_application_source` | medium | None | None | accept |
| R074 | `lib/shared/platforms/showroom/showroom_site.dart` | `other_application_source` | medium | None | None | accept |
| A | `lib/shared/platforms/sixroom/six_room_danmaku.dart` | `other_application_source` | medium | 312 | 0 | accept |
| R095 | `lib/shared/platforms/sixroom/sixroom_api.dart` | `other_application_source` | medium | None | None | accept |
| R100 | `lib/shared/platforms/sixroom/sixroom_link.dart` | `other_application_source` | medium | None | None | accept |
| R069 | `lib/shared/platforms/sixroom/sixroom_site.dart` | `other_application_source` | medium | None | None | accept |
| R090 | `lib/shared/platforms/soop/soop_danmaku.dart` | `other_application_source` | medium | None | None | accept |
| R081 | `lib/shared/platforms/soop/soop_site.dart` | `other_application_source` | medium | None | None | accept |
| R090 | `lib/shared/platforms/steambroadcast/steam_broadcast_api.dart` | `other_application_source` | medium | None | None | accept |
| A | `lib/shared/platforms/steambroadcast/steam_broadcast_danmaku.dart` | `other_application_source` | medium | 238 | 0 | accept |
| R100 | `lib/shared/platforms/steambroadcast/steam_broadcast_link.dart` | `other_application_source` | medium | None | None | accept |
| R064 | `lib/shared/platforms/steambroadcast/steam_broadcast_site.dart` | `other_application_source` | medium | None | None | accept |
| R081 | `lib/shared/platforms/tiktok/tiktok_api.dart` | `other_application_source` | medium | None | None | accept |
| R086 | `lib/shared/platforms/tiktok/tiktok_link.dart` | `other_application_source` | medium | None | None | accept |
| R054 | `lib/shared/platforms/tiktok/tiktok_site.dart` | `other_application_source` | medium | None | None | accept |
| R088 | `lib/shared/platforms/twitcasting/twitcasting_api.dart` | `other_application_source` | medium | None | None | accept |
| A | `lib/shared/platforms/twitcasting/twitcasting_danmaku.dart` | `other_application_source` | medium | 187 | 0 | accept |
| A | `lib/shared/platforms/twitcasting/twitcasting_site.dart` | `other_application_source` | medium | 132 | 0 | accept |
| R053 | `lib/shared/platforms/twitch/twitch_danmaku.dart` | `other_application_source` | medium | None | None | accept |
| R096 | `lib/shared/platforms/twitch/twitch_models.dart` | `other_application_source` | medium | None | None | accept |
| R090 | `lib/shared/platforms/twitch/twitch_site.dart` | `other_application_source` | medium | None | None | accept |
| R093 | `lib/shared/platforms/twitch/twitch_web_integrity.dart` | `other_application_source` | medium | None | None | accept |
| R085 | `lib/shared/platforms/weibo/weibo_api.dart` | `other_application_source` | medium | None | None | accept |
| R100 | `lib/shared/platforms/weibo/weibo_link.dart` | `other_application_source` | medium | None | None | accept |
| R072 | `lib/shared/platforms/weibo/weibo_site.dart` | `other_application_source` | medium | None | None | accept |
| R095 | `lib/shared/platforms/xiaohongshu/xiaohongshu_api.dart` | `other_application_source` | medium | None | None | accept |
| R078 | `lib/shared/platforms/xiaohongshu/xiaohongshu_link.dart` | `other_application_source` | medium | None | None | accept |
| R097 | `lib/shared/platforms/xiaohongshu/xiaohongshu_share.dart` | `other_application_source` | medium | None | None | accept |
| R063 | `lib/shared/platforms/xiaohongshu/xiaohongshu_site.dart` | `other_application_source` | medium | None | None | accept |
| R098 | `lib/shared/platforms/youtube/youtube_api.dart` | `other_application_source` | medium | None | None | accept |
| R100 | `lib/shared/platforms/youtube/youtube_link.dart` | `other_application_source` | medium | None | None | accept |
| R059 | `lib/shared/platforms/youtube/youtube_site.dart` | `other_application_source` | medium | None | None | accept |
| R088 | `lib/shared/platforms/yy/yy_danmaku.dart` | `other_application_source` | medium | None | None | accept |
| R095 | `lib/shared/platforms/yy/yy_protocol.dart` | `other_application_source` | medium | None | None | accept |
| R083 | `lib/shared/platforms/yy/yy_site.dart` | `other_application_source` | medium | None | None | accept |
| R100 | `lib/shared/platforms/yy/yy_web_socket_channel.dart` | `other_application_source` | medium | None | None | accept |
| M | `linux/CMakeLists.txt` | `linux_native` | high | 26 | 0 | accept |
| M | `linux/flutter/generated_plugin_registrant.cc` | `linux_native` | high | 4 | 4 | accept |
| M | `linux/flutter/generated_plugins.cmake` | `linux_native` | high | 1 | 1 | accept |
| A | `linux/packaging/deb/make_config.yaml` | `linux_native` | high | 28 | 0 | accept |
| M | `plugins/built_in_kotlin/README.md` | `dependencies_and_vendored` | high | 6 | 12 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/CHANGELOG.md` | `dependencies_and_vendored` | high | 0 | 148 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/LICENSE` | `dependencies_and_vendored` | high | 0 | 201 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/README.md` | `dependencies_and_vendored` | high | 0 | 126 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/analysis_options.yaml` | `dependencies_and_vendored` | high | 0 | 11 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/android/build.gradle.kts` | `dependencies_and_vendored` | high | 0 | 60 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/android/gradle/wrapper/gradle-wrapper.properties` | `dependencies_and_vendored` | high | 0 | 5 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/android/settings.gradle.kts` | `dependencies_and_vendored` | high | 0 | 1 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/android/src/main/AndroidManifest.xml` | `dependencies_and_vendored` | high | 0 | 19 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/android/src/main/kotlin/uz/shs/better_player_plus/BetterPlayer.kt` | `dependencies_and_vendored` | high | 0 | 868 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/android/src/main/kotlin/uz/shs/better_player_plus/BetterPlayerCache.kt` | `dependencies_and_vendored` | high | 0 | 42 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/android/src/main/kotlin/uz/shs/better_player_plus/BetterPlayerForegroundService.kt` | `dependencies_and_vendored` | high | 0 | 205 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/android/src/main/kotlin/uz/shs/better_player_plus/BetterPlayerPlugin.kt` | `dependencies_and_vendored` | high | 0 | 606 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/android/src/main/kotlin/uz/shs/better_player_plus/CacheDataSourceFactory.kt` | `dependencies_and_vendored` | high | 0 | 41 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/android/src/main/kotlin/uz/shs/better_player_plus/CacheWorker.kt` | `dependencies_and_vendored` | high | 0 | 101 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/android/src/main/kotlin/uz/shs/better_player_plus/CustomDefaultLoadControl.kt` | `dependencies_and_vendored` | high | 0 | 57 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/android/src/main/kotlin/uz/shs/better_player_plus/DataSourceUtils.kt` | `dependencies_and_vendored` | high | 0 | 55 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/android/src/main/kotlin/uz/shs/better_player_plus/ImageWorker.kt` | `dependencies_and_vendored` | high | 0 | 117 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/android/src/main/kotlin/uz/shs/better_player_plus/QueuingEventSink.kt` | `dependencies_and_vendored` | high | 0 | 76 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/ios/better_player_plus.podspec` | `dependencies_and_vendored` | high | 0 | 25 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/ios/better_player_plus/Package.swift` | `dependencies_and_vendored` | high | 0 | 52 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/ios/better_player_plus/Sources/GCDWebServer/GCDWebServer.swift` | `dependencies_and_vendored` | high | 0 | 10 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/ios/better_player_plus/Sources/HLSCachingReverseProxyServer/HLSCachingReverseProxyServer.swift` | `dependencies_and_vendored` | high | 0 | 20 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/ios/better_player_plus/Sources/PINCache/PINCache.swift` | `dependencies_and_vendored` | high | 0 | 8 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/ios/better_player_plus/Sources/better_player_plus/BetterPlayer.swift` | `dependencies_and_vendored` | high | 0 | 627 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/ios/better_player_plus/Sources/better_player_plus/BetterPlayerEzDrmAssetsLoaderDelegate.swift` | `dependencies_and_vendored` | high | 0 | 86 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/ios/better_player_plus/Sources/better_player_plus/BetterPlayerPlugin.h` | `dependencies_and_vendored` | high | 0 | 5 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/ios/better_player_plus/Sources/better_player_plus/BetterPlayerPlugin.m` | `dependencies_and_vendored` | high | 0 | 8 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/ios/better_player_plus/Sources/better_player_plus/BetterPlayerTimeUtils.swift` | `dependencies_and_vendored` | high | 0 | 13 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/ios/better_player_plus/Sources/better_player_plus/BetterPlayerView.swift` | `dependencies_and_vendored` | high | 0 | 18 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/ios/better_player_plus/Sources/better_player_plus/CacheManager.swift` | `dependencies_and_vendored` | high | 0 | 226 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/ios/better_player_plus/Sources/better_player_plus/CachingPlayerItem.swift` | `dependencies_and_vendored` | high | 0 | 285 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/ios/better_player_plus/Sources/better_player_plus/PrivacyInfo.xcprivacy` | `dependencies_and_vendored` | high | 0 | 14 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/ios/better_player_plus/Sources/better_player_plus/SwiftBetterPlayerPlugin.swift` | `dependencies_and_vendored` | high | 0 | 368 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/lib/better_player_plus.dart` | `dependencies_and_vendored` | high | 0 | 37 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/lib/src/asms/better_player_asms_audio_track.dart` | `dependencies_and_vendored` | high | 0 | 32 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/lib/src/asms/better_player_asms_data_holder.dart` | `dependencies_and_vendored` | high | 0 | 10 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/lib/src/asms/better_player_asms_subtitle.dart` | `dependencies_and_vendored` | high | 0 | 48 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/lib/src/asms/better_player_asms_subtitle_segment.dart` | `dependencies_and_vendored` | high | 0 | 15 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/lib/src/asms/better_player_asms_track.dart` | `dependencies_and_vendored` | high | 0 | 51 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/lib/src/asms/better_player_asms_utils.dart` | `dependencies_and_vendored` | high | 0 | 51 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/lib/src/clearkey/better_player_clearkey_utils.dart` | `dependencies_and_vendored` | high | 0 | 38 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/lib/src/configuration/better_player_buffering_configuration.dart` | `dependencies_and_vendored` | high | 0 | 34 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/lib/src/configuration/better_player_cache_configuration.dart` | `dependencies_and_vendored` | high | 0 | 32 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/lib/src/configuration/better_player_configuration.dart` | `dependencies_and_vendored` | high | 0 | 224 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/lib/src/configuration/better_player_controller_event.dart` | `dependencies_and_vendored` | high | 0 | 23 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/lib/src/configuration/better_player_controls_configuration.dart` | `dependencies_and_vendored` | high | 0 | 246 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/lib/src/configuration/better_player_data_source.dart` | `dependencies_and_vendored` | high | 0 | 241 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/lib/src/configuration/better_player_data_source_type.dart` | `dependencies_and_vendored` | high | 0 | 4 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/lib/src/configuration/better_player_drm_configuration.dart` | `dependencies_and_vendored` | high | 0 | 31 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/lib/src/configuration/better_player_drm_type.dart` | `dependencies_and_vendored` | high | 0 | 6 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/lib/src/configuration/better_player_event.dart` | `dependencies_and_vendored` | high | 0 | 9 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/lib/src/configuration/better_player_event_type.dart` | `dependencies_and_vendored` | high | 0 | 28 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/lib/src/configuration/better_player_notification_configuration.dart` | `dependencies_and_vendored` | high | 0 | 31 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/lib/src/configuration/better_player_theme.dart` | `dependencies_and_vendored` | high | 0 | 4 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/lib/src/configuration/better_player_translations.dart` | `dependencies_and_vendored` | high | 0 | 141 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/lib/src/configuration/better_player_video_format.dart` | `dependencies_and_vendored` | high | 0 | 2 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/lib/src/controls/better_player_clickable_widget.dart` | `dependencies_and_vendored` | high | 0 | 16 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/lib/src/controls/better_player_controls_state.dart` | `dependencies_and_vendored` | high | 0 | 447 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/lib/src/controls/better_player_cupertino_controls.dart` | `dependencies_and_vendored` | high | 0 | 639 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/lib/src/controls/better_player_cupertino_progress_bar.dart` | `dependencies_and_vendored` | high | 0 | 256 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/lib/src/controls/better_player_material_controls.dart` | `dependencies_and_vendored` | high | 0 | 596 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/lib/src/controls/better_player_material_progress_bar.dart` | `dependencies_and_vendored` | high | 0 | 248 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/lib/src/controls/better_player_multiple_gesture_detector.dart` | `dependencies_and_vendored` | high | 0 | 22 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/lib/src/controls/better_player_overflow_menu_item.dart` | `dependencies_and_vendored` | high | 0 | 16 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/lib/src/controls/better_player_progress_colors.dart` | `dependencies_and_vendored` | high | 0 | 20 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/lib/src/core/better_player.dart` | `dependencies_and_vendored` | high | 0 | 245 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/lib/src/core/better_player_controller.dart` | `dependencies_and_vendored` | high | 0 | 1241 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/lib/src/core/better_player_controller_provider.dart` | `dependencies_and_vendored` | high | 0 | 12 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/lib/src/core/better_player_utils.dart` | `dependencies_and_vendored` | high | 0 | 67 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/lib/src/core/better_player_with_controls.dart` | `dependencies_and_vendored` | high | 0 | 320 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/lib/src/enum/aspect_enum.dart` | `dependencies_and_vendored` | high | 0 | 10 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/lib/src/hls/better_player_hls_utils.dart` | `dependencies_and_vendored` | high | 0 | 186 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/lib/src/hls/hls_parser/drm_init_data.dart` | `dependencies_and_vendored` | high | 0 | 22 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/lib/src/hls/hls_parser/exception.dart` | `dependencies_and_vendored` | high | 0 | 14 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/lib/src/hls/hls_parser/format.dart` | `dependencies_and_vendored` | high | 0 | 139 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/lib/src/hls/hls_parser/hls_master_playlist.dart` | `dependencies_and_vendored` | high | 0 | 67 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/lib/src/hls/hls_parser/hls_media_playlist.dart` | `dependencies_and_vendored` | high | 0 | 113 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/lib/src/hls/hls_parser/hls_playlist_parser.dart` | `dependencies_and_vendored` | high | 0 | 962 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/lib/src/hls/hls_parser/hls_track_metadata_entry.dart` | `dependencies_and_vendored` | high | 0 | 32 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/lib/src/hls/hls_parser/metadata.dart` | `dependencies_and_vendored` | high | 0 | 21 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/lib/src/hls/hls_parser/mime_types.dart` | `dependencies_and_vendored` | high | 0 | 284 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/lib/src/hls/hls_parser/playlist.dart` | `dependencies_and_vendored` | high | 0 | 12 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/lib/src/hls/hls_parser/rendition.dart` | `dependencies_and_vendored` | high | 0 | 17 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/lib/src/hls/hls_parser/scheme_data.dart` | `dependencies_and_vendored` | high | 0 | 41 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/lib/src/hls/hls_parser/segment.dart` | `dependencies_and_vendored` | high | 0 | 54 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/lib/src/hls/hls_parser/util.dart` | `dependencies_and_vendored` | high | 0 | 143 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/lib/src/hls/hls_parser/variant.dart` | `dependencies_and_vendored` | high | 0 | 40 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/lib/src/hls/hls_parser/variant_info.dart` | `dependencies_and_vendored` | high | 0 | 40 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/lib/src/list/better_player_list_video_player.dart` | `dependencies_and_vendored` | high | 0 | 96 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/lib/src/list/better_player_list_video_player_controller.dart` | `dependencies_and_vendored` | high | 0 | 32 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/lib/src/playlist/better_player_playlist.dart` | `dependencies_and_vendored` | high | 0 | 53 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/lib/src/playlist/better_player_playlist_configuration.dart` | `dependencies_and_vendored` | high | 0 | 18 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/lib/src/playlist/better_player_playlist_controller.dart` | `dependencies_and_vendored` | high | 0 | 141 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/lib/src/subtitles/better_player_subtitle.dart` | `dependencies_and_vendored` | high | 0 | 113 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/lib/src/subtitles/better_player_subtitles_configuration.dart` | `dependencies_and_vendored` | high | 0 | 53 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/lib/src/subtitles/better_player_subtitles_drawer.dart` | `dependencies_and_vendored` | high | 0 | 143 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/lib/src/subtitles/better_player_subtitles_factory.dart` | `dependencies_and_vendored` | high | 0 | 105 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/lib/src/subtitles/better_player_subtitles_source.dart` | `dependencies_and_vendored` | high | 0 | 69 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/lib/src/subtitles/better_player_subtitles_source_type.dart` | `dependencies_and_vendored` | high | 0 | 2 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/lib/src/video_player/method_channel_video_player.dart` | `dependencies_and_vendored` | high | 0 | 305 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/lib/src/video_player/video_player.dart` | `dependencies_and_vendored` | high | 0 | 955 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/lib/src/video_player/video_player_platform_interface.dart` | `dependencies_and_vendored` | high | 0 | 512 | accept |
| D | `plugins/built_in_kotlin/better_player_plus/pubspec.yaml` | `dependencies_and_vendored` | high | 0 | 34 | accept |
| D | `plugins/built_in_kotlin/floating/CHANGELOG.md` | `dependencies_and_vendored` | high | 0 | 103 | accept |
| D | `plugins/built_in_kotlin/floating/LICENSE` | `dependencies_and_vendored` | high | 0 | 9 | accept |
| D | `plugins/built_in_kotlin/floating/README.md` | `dependencies_and_vendored` | high | 0 | 100 | accept |
| D | `plugins/built_in_kotlin/floating/analysis_options.yaml` | `dependencies_and_vendored` | high | 0 | 4 | accept |
| D | `plugins/built_in_kotlin/floating/android/build.gradle` | `dependencies_and_vendored` | high | 0 | 45 | accept |
| D | `plugins/built_in_kotlin/floating/android/settings.gradle` | `dependencies_and_vendored` | high | 0 | 1 | accept |
| D | `plugins/built_in_kotlin/floating/android/src/main/AndroidManifest.xml` | `dependencies_and_vendored` | high | 0 | 3 | accept |
| D | `plugins/built_in_kotlin/floating/android/src/main/kotlin/eu/wroblewscy/marcin/floating/floating/FloatingPlugin.kt` | `dependencies_and_vendored` | high | 0 | 134 | accept |
| D | `plugins/built_in_kotlin/floating/assets/cover.png` | `dependencies_and_vendored` | high | None | None | accept |
| D | `plugins/built_in_kotlin/floating/lib/floating.dart` | `dependencies_and_vendored` | high | 0 | 8 | accept |
| D | `plugins/built_in_kotlin/floating/lib/src/enable_arguments.dart` | `dependencies_and_vendored` | high | 0 | 51 | accept |
| D | `plugins/built_in_kotlin/floating/lib/src/floating.dart` | `dependencies_and_vendored` | high | 0 | 280 | accept |
| D | `plugins/built_in_kotlin/floating/lib/src/pip_switcher.dart` | `dependencies_and_vendored` | high | 0 | 53 | accept |
| D | `plugins/built_in_kotlin/floating/pubspec.yaml` | `dependencies_and_vendored` | high | 0 | 34 | accept |
| D | `plugins/flame_barrage/CHANGELOG.md` | `dependencies_and_vendored` | high | 0 | 40 | accept |
| D | `plugins/flame_barrage/LICENSE` | `dependencies_and_vendored` | high | 0 | 21 | accept |
| D | `plugins/flame_barrage/README.md` | `dependencies_and_vendored` | high | 0 | 341 | accept |
| D | `plugins/flame_barrage/lib/flame_barrage.dart` | `dependencies_and_vendored` | high | 0 | 91 | accept |
| D | `plugins/flame_barrage/lib/src/animation/combo_animation.dart` | `dependencies_and_vendored` | high | 0 | 72 | accept |
| D | `plugins/flame_barrage/lib/src/animation/sprite_animation_player.dart` | `dependencies_and_vendored` | high | 0 | 28 | accept |
| D | `plugins/flame_barrage/lib/src/atlas/atlas_loader.dart` | `dependencies_and_vendored` | high | 0 | 16 | accept |
| D | `plugins/flame_barrage/lib/src/atlas/emoji_atlas.dart` | `dependencies_and_vendored` | high | 0 | 143 | accept |
| D | `plugins/flame_barrage/lib/src/atlas/sprite_sheet.dart` | `dependencies_and_vendored` | high | 0 | 36 | accept |
| D | `plugins/flame_barrage/lib/src/cache/atlas_cache.dart` | `dependencies_and_vendored` | high | 0 | 29 | accept |
| D | `plugins/flame_barrage/lib/src/cache/picture_cache.dart` | `dependencies_and_vendored` | high | 0 | 47 | accept |
| D | `plugins/flame_barrage/lib/src/cache/sprite_cache.dart` | `dependencies_and_vendored` | high | 0 | 24 | accept |
| D | `plugins/flame_barrage/lib/src/cache/text_cache.dart` | `dependencies_and_vendored` | high | 0 | 49 | accept |
| D | `plugins/flame_barrage/lib/src/components/barrage_component.dart` | `dependencies_and_vendored` | high | 0 | 65 | accept |
| D | `plugins/flame_barrage/lib/src/core/barrage_config.dart` | `dependencies_and_vendored` | high | 0 | 289 | accept |
| D | `plugins/flame_barrage/lib/src/core/barrage_context.dart` | `dependencies_and_vendored` | high | 0 | 11 | accept |
| D | `plugins/flame_barrage/lib/src/core/barrage_controller.dart` | `dependencies_and_vendored` | high | 0 | 106 | accept |
| D | `plugins/flame_barrage/lib/src/core/barrage_engine.dart` | `dependencies_and_vendored` | high | 0 | 642 | accept |
| D | `plugins/flame_barrage/lib/src/core/barrage_layer.dart` | `dependencies_and_vendored` | high | 0 | 22 | accept |
| D | `plugins/flame_barrage/lib/src/core/engine_clock.dart` | `dependencies_and_vendored` | high | 0 | 28 | accept |
| D | `plugins/flame_barrage/lib/src/effect/barrage_effect_interceptor.dart` | `dependencies_and_vendored` | high | 0 | 21 | accept |
| D | `plugins/flame_barrage/lib/src/effect/glow_effect.dart` | `dependencies_and_vendored` | high | 0 | 15 | accept |
| D | `plugins/flame_barrage/lib/src/effect/gradient_effect.dart` | `dependencies_and_vendored` | high | 0 | 15 | accept |
| D | `plugins/flame_barrage/lib/src/effect/shadow_effect.dart` | `dependencies_and_vendored` | high | 0 | 26 | accept |
| D | `plugins/flame_barrage/lib/src/effect/stroke_effect.dart` | `dependencies_and_vendored` | high | 0 | 17 | accept |
| D | `plugins/flame_barrage/lib/src/layout/emoji_fragment.dart` | `dependencies_and_vendored` | high | 0 | 8 | accept |
| D | `plugins/flame_barrage/lib/src/layout/emoji_layout_span.dart` | `dependencies_and_vendored` | high | 0 | 29 | accept |
| D | `plugins/flame_barrage/lib/src/layout/fragment.dart` | `dependencies_and_vendored` | high | 0 | 3 | accept |
| D | `plugins/flame_barrage/lib/src/layout/layout_result.dart` | `dependencies_and_vendored` | high | 0 | 13 | accept |
| D | `plugins/flame_barrage/lib/src/layout/layout_span.dart` | `dependencies_and_vendored` | high | 0 | 40 | accept |
| D | `plugins/flame_barrage/lib/src/layout/mixed_layout.dart` | `dependencies_and_vendored` | high | 0 | 372 | accept |
| D | `plugins/flame_barrage/lib/src/layout/rich_parser.dart` | `dependencies_and_vendored` | high | 0 | 104 | accept |
| D | `plugins/flame_barrage/lib/src/layout/sprite_fragment.dart` | `dependencies_and_vendored` | high | 0 | 6 | accept |
| D | `plugins/flame_barrage/lib/src/layout/sprite_layout_span.dart` | `dependencies_and_vendored` | high | 0 | 39 | accept |
| D | `plugins/flame_barrage/lib/src/layout/text_fragment.dart` | `dependencies_and_vendored` | high | 0 | 7 | accept |
| D | `plugins/flame_barrage/lib/src/model/barrage/barrage_entry.dart` | `dependencies_and_vendored` | high | 0 | 77 | accept |
| D | `plugins/flame_barrage/lib/src/model/barrage/barrage_item.dart` | `dependencies_and_vendored` | high | 0 | 70 | accept |
| D | `plugins/flame_barrage/lib/src/model/barrage/barrage_track.dart` | `dependencies_and_vendored` | high | 0 | 28 | accept |
| D | `plugins/flame_barrage/lib/src/model/barrage/barrage_type.dart` | `dependencies_and_vendored` | high | 0 | 11 | accept |
| D | `plugins/flame_barrage/lib/src/model/barrage/engine_state.dart` | `dependencies_and_vendored` | high | 0 | 1 | accept |
| D | `plugins/flame_barrage/lib/src/model/base_message.dart` | `dependencies_and_vendored` | high | 0 | 34 | accept |
| D | `plugins/flame_barrage/lib/src/model/emoji/emogi_source_type.dart` | `dependencies_and_vendored` | high | 0 | 39 | accept |
| D | `plugins/flame_barrage/lib/src/model/emoji/emoji_info.dart` | `dependencies_and_vendored` | high | 0 | 19 | accept |
| D | `plugins/flame_barrage/lib/src/pool/barrage_pool.dart` | `dependencies_and_vendored` | high | 0 | 39 | accept |
| D | `plugins/flame_barrage/lib/src/pool/object_pool.dart` | `dependencies_and_vendored` | high | 0 | 26 | accept |
| D | `plugins/flame_barrage/lib/src/pool/picture_pool.dart` | `dependencies_and_vendored` | high | 0 | 33 | accept |
| D | `plugins/flame_barrage/lib/src/protocol/emoji_protocol.dart` | `dependencies_and_vendored` | high | 0 | 27 | accept |
| D | `plugins/flame_barrage/lib/src/protocol/message_protocol.dart` | `dependencies_and_vendored` | high | 0 | 26 | accept |
| D | `plugins/flame_barrage/lib/src/render/barrage/barrage_renderer.dart` | `dependencies_and_vendored` | high | 0 | 37 | accept |
| D | `plugins/flame_barrage/lib/src/render/barrage/emoji_renderer.dart` | `dependencies_and_vendored` | high | 0 | 9 | accept |
| D | `plugins/flame_barrage/lib/src/render/barrage/mixed_renderer.dart` | `dependencies_and_vendored` | high | 0 | 24 | accept |
| D | `plugins/flame_barrage/lib/src/render/base_renderer.dart` | `dependencies_and_vendored` | high | 0 | 6 | accept |
| D | `plugins/flame_barrage/lib/src/scheduler/overlap_detector.dart` | `dependencies_and_vendored` | high | 0 | 25 | accept |
| D | `plugins/flame_barrage/lib/src/scheduler/speed_strategy.dart` | `dependencies_and_vendored` | high | 0 | 38 | accept |
| D | `plugins/flame_barrage/lib/src/scheduler/track_allocator.dart` | `dependencies_and_vendored` | high | 0 | 44 | accept |
| D | `plugins/flame_barrage/lib/src/scheduler/track_manager.dart` | `dependencies_and_vendored` | high | 0 | 48 | accept |
| D | `plugins/flame_barrage/lib/src/util/barrage_logger.dart` | `dependencies_and_vendored` | high | 0 | 29 | accept |
| D | `plugins/flame_barrage/lib/src/util/color_util.dart` | `dependencies_and_vendored` | high | 0 | 20 | accept |
| D | `plugins/flame_barrage/lib/src/util/fps_monitor.dart` | `dependencies_and_vendored` | high | 0 | 52 | accept |
| D | `plugins/flame_barrage/lib/src/util/measure.dart` | `dependencies_and_vendored` | high | 0 | 22 | accept |
| D | `plugins/flame_barrage/lib/src/widget/barrage_overlay.dart` | `dependencies_and_vendored` | high | 0 | 47 | accept |
| D | `plugins/flame_barrage/lib/src/widget/flame_barrage_widget.dart` | `dependencies_and_vendored` | high | 0 | 109 | accept |
| D | `plugins/flame_barrage/pubspec.lock` | `dependencies_and_vendored` | high | 0 | 221 | accept |
| D | `plugins/flame_barrage/pubspec.yaml` | `dependencies_and_vendored` | high | 0 | 25 | accept |
| D | `plugins/flv_lzc/.gitignore` | `dependencies_and_vendored` | high | 0 | 7 | accept |
| D | `plugins/flv_lzc/CHANGELOG.md` | `dependencies_and_vendored` | high | 0 | 362 | accept |
| D | `plugins/flv_lzc/LICENSE` | `dependencies_and_vendored` | high | 0 | 21 | accept |
| D | `plugins/flv_lzc/README.md` | `dependencies_and_vendored` | high | 0 | 106 | accept |
| D | `plugins/flv_lzc/analysis_options.yaml` | `dependencies_and_vendored` | high | 0 | 4 | accept |
| D | `plugins/flv_lzc/android/build.gradle` | `dependencies_and_vendored` | high | 0 | 60 | accept |
| D | `plugins/flv_lzc/android/gradle.properties` | `dependencies_and_vendored` | high | 0 | 1 | accept |
| D | `plugins/flv_lzc/android/libs/COPYING.LGPLv2.1` | `dependencies_and_vendored` | high | 0 | 502 | accept |
| D | `plugins/flv_lzc/android/libs/NOTICE` | `dependencies_and_vendored` | high | 0 | 189 | accept |
| D | `plugins/flv_lzc/android/libs/README.md` | `dependencies_and_vendored` | high | 0 | 53 | accept |
| D | `plugins/flv_lzc/android/libs/fplayer-core-1.0.4-purelive-16kb.patch` | `dependencies_and_vendored` | high | 0 | 32 | accept |
| D | `plugins/flv_lzc/android/libs/io/github/flutterplayer/fplayer-core/1.0.4-purelive16k/fplayer-core-1.0.4-purelive16k.aar` | `dependencies_and_vendored` | high | None | None | accept |
| D | `plugins/flv_lzc/android/libs/io/github/flutterplayer/fplayer-core/1.0.4-purelive16k/fplayer-core-1.0.4-purelive16k.pom` | `dependencies_and_vendored` | high | 0 | 24 | accept |
| D | `plugins/flv_lzc/android/settings.gradle` | `dependencies_and_vendored` | high | 0 | 1 | accept |
| D | `plugins/flv_lzc/android/src/main/AndroidManifest.xml` | `dependencies_and_vendored` | high | 0 | 3 | accept |
| D | `plugins/flv_lzc/android/src/main/java/com/befovy/fijkplayer/FijkEngine.java` | `dependencies_and_vendored` | high | 0 | 55 | accept |
| D | `plugins/flv_lzc/android/src/main/java/com/befovy/fijkplayer/FijkPlayer.java` | `dependencies_and_vendored` | high | 0 | 493 | accept |
| D | `plugins/flv_lzc/android/src/main/java/com/befovy/fijkplayer/FijkPlugin.java` | `dependencies_and_vendored` | high | 0 | 657 | accept |
| D | `plugins/flv_lzc/android/src/main/java/com/befovy/fijkplayer/FijkVolume.java` | `dependencies_and_vendored` | high | 0 | 36 | accept |
| D | `plugins/flv_lzc/android/src/main/java/com/befovy/fijkplayer/FileMediaDataSource.java` | `dependencies_and_vendored` | high | 0 | 83 | accept |
| D | `plugins/flv_lzc/android/src/main/java/com/befovy/fijkplayer/HostOption.java` | `dependencies_and_vendored` | high | 0 | 76 | accept |
| D | `plugins/flv_lzc/android/src/main/java/com/befovy/fijkplayer/QueuingEventSink.java` | `dependencies_and_vendored` | high | 0 | 106 | accept |
| D | `plugins/flv_lzc/android/src/main/java/com/befovy/fijkplayer/RawMediaDataSource.java` | `dependencies_and_vendored` | high | 0 | 81 | accept |
| D | `plugins/flv_lzc/android/src/test/kotlin/com/befovy/fepe_fijkplayer/FepeFijkplayerPluginTest.kt` | `dependencies_and_vendored` | high | 0 | 27 | accept |
| D | `plugins/flv_lzc/ios/Classes/FijkHostOption.h` | `dependencies_and_vendored` | high | 0 | 43 | accept |
| D | `plugins/flv_lzc/ios/Classes/FijkHostOption.m` | `dependencies_and_vendored` | high | 0 | 64 | accept |
| D | `plugins/flv_lzc/ios/Classes/FijkPlayer.h` | `dependencies_and_vendored` | high | 0 | 43 | accept |
| D | `plugins/flv_lzc/ios/Classes/FijkPlayer.m` | `dependencies_and_vendored` | high | 0 | 588 | accept |
| D | `plugins/flv_lzc/ios/Classes/FijkPlugin.h` | `dependencies_and_vendored` | high | 0 | 32 | accept |
| D | `plugins/flv_lzc/ios/Classes/FijkPlugin.m` | `dependencies_and_vendored` | high | 0 | 361 | accept |
| D | `plugins/flv_lzc/ios/Classes/FijkQueuingEventSink.h` | `dependencies_and_vendored` | high | 0 | 42 | accept |
| D | `plugins/flv_lzc/ios/Classes/FijkQueuingEventSink.m` | `dependencies_and_vendored` | high | 0 | 89 | accept |
| D | `plugins/flv_lzc/ios/flv_lzc.podspec` | `dependencies_and_vendored` | high | 0 | 34 | accept |
| D | `plugins/flv_lzc/lib/core/fijklog.dart` | `dependencies_and_vendored` | high | 0 | 125 | accept |
| D | `plugins/flv_lzc/lib/core/fijkoption.dart` | `dependencies_and_vendored` | high | 0 | 135 | accept |
| D | `plugins/flv_lzc/lib/core/fijkplayer.dart` | `dependencies_and_vendored` | high | 0 | 594 | accept |
| D | `plugins/flv_lzc/lib/core/fijkplugin.dart` | `dependencies_and_vendored` | high | 0 | 185 | accept |
| D | `plugins/flv_lzc/lib/core/fijkvalue.dart` | `dependencies_and_vendored` | high | 0 | 380 | accept |
| D | `plugins/flv_lzc/lib/core/fijkview.dart` | `dependencies_and_vendored` | high | 0 | 534 | accept |
| D | `plugins/flv_lzc/lib/core/fijkvol.dart` | `dependencies_and_vendored` | high | 0 | 261 | accept |
| D | `plugins/flv_lzc/lib/fijkplayer.dart` | `dependencies_and_vendored` | high | 0 | 46 | accept |
| D | `plugins/flv_lzc/lib/ui/panel.dart` | `dependencies_and_vendored` | high | 0 | 319 | accept |
| D | `plugins/flv_lzc/lib/ui/panel2.dart` | `dependencies_and_vendored` | high | 0 | 618 | accept |
| D | `plugins/flv_lzc/lib/ui/slider.dart` | `dependencies_and_vendored` | high | 0 | 218 | accept |
| D | `plugins/flv_lzc/lib/ui/volume.dart` | `dependencies_and_vendored` | high | 0 | 111 | accept |
| D | `plugins/flv_lzc/pubspec.yaml` | `dependencies_and_vendored` | high | 0 | 60 | accept |
| D | `plugins/windows_single_instance/pubspec.lock` | `dependencies_and_vendored` | high | 0 | 229 | accept |
| M | `pubspec.lock` | `dependencies_and_vendored` | high | 334 | 138 | accept |
| M | `pubspec.yaml` | `dependencies_and_vendored` | high | 135 | 51 | accept |
| D | `test/about_update_prompt_layout_test.dart` | `tests` | low | 0 | 228 | accept |
| D | `test/account_cookie_editor_test.dart` | `tests` | low | 0 | 325 | accept |
| D | `test/account_identity_lifecycle_test.dart` | `tests` | low | 0 | 242 | accept |
| D | `test/account_page_navigation_test.dart` | `tests` | low | 0 | 321 | accept |
| D | `test/acfun_adapter_contract_test.dart` | `tests` | low | 0 | 350 | accept |
| D | `test/acfun_catalog_migration_test.dart` | `tests` | low | 0 | 87 | accept |
| D | `test/acfun_navigation_test.dart` | `tests` | low | 0 | 494 | accept |
| D | `test/active_video_content_analyzer_test.dart` | `tests` | low | 0 | 69 | accept |
| D | `test/adaptive_refresh_rate_scope_test.dart` | `tests` | low | 0 | 93 | accept |
| D | `test/android_native_http_test.dart` | `tests` | low | 0 | 43 | accept |
| D | `test/android_surface_contract_test.dart` | `tests` | low | 0 | 17 | accept |
| D | `test/android_volume_key_routing_test.dart` | `tests` | low | 0 | 24 | accept |
| D | `test/app_color_picker_dialog_test.dart` | `tests` | low | 0 | 119 | accept |
| D | `test/app_initializer_recorder_policy_test.dart` | `tests` | low | 0 | 9 | accept |
| D | `test/app_path_manager_test.dart` | `tests` | low | 0 | 28 | accept |
| D | `test/app_settings_audience_platform_persistence_test.dart` | `tests` | low | 0 | 91 | accept |
| D | `test/app_settings_controller_test.dart` | `tests` | low | 0 | 111 | accept |
| D | `test/app_status_view_lifecycle_test.dart` | `tests` | low | 0 | 254 | accept |
| D | `test/area_artwork_test.dart` | `tests` | low | 0 | 203 | accept |
| D | `test/area_card_layout_test.dart` | `tests` | low | 0 | 79 | accept |
| D | `test/area_category_paging_test.dart` | `tests` | low | 0 | 146 | accept |
| D | `test/area_category_switch_test.dart` | `tests` | low | 0 | 50 | accept |
| D | `test/area_tab_refresh_test.dart` | `tests` | low | 0 | 419 | accept |
| D | `test/audience_metric_settings_page_test.dart` | `tests` | low | 0 | 352 | accept |
| D | `test/audio_only_button_test.dart` | `tests` | low | 0 | 110 | accept |
| D | `test/background_playback_policy_test.dart` | `tests` | low | 0 | 47 | accept |
| D | `test/backup_collection_validation_test.dart` | `tests` | low | 0 | 188 | accept |
| D | `test/backup_import_validation_test.dart` | `tests` | low | 0 | 284 | accept |
| D | `test/backup_page_test.dart` | `tests` | low | 0 | 225 | accept |
| D | `test/backup_privacy_test.dart` | `tests` | low | 0 | 29 | accept |
| D | `test/backup_roundtrip_test.dart` | `tests` | low | 0 | 361 | accept |
| D | `test/backup_settings_layout_test.dart` | `tests` | low | 0 | 326 | accept |
| D | `test/baidu_live_catalog_migration_test.dart` | `tests` | low | 0 | 50 | accept |
| D | `test/baidu_live_site_test.dart` | `tests` | low | 0 | 210 | accept |
| D | `test/barrage_queue_test.dart` | `tests` | low | 0 | 203 | accept |
| D | `test/base_page_layout_test.dart` | `tests` | low | 0 | 396 | accept |
| D | `test/bigo_api_test.dart` | `tests` | low | 0 | 294 | accept |
| D | `test/bigo_catalog_migration_test.dart` | `tests` | low | 0 | 50 | accept |
| D | `test/bigo_hls_input_test.dart` | `tests` | low | 0 | 125 | accept |
| D | `test/bigo_media_test.dart` | `tests` | low | 0 | 137 | accept |
| D | `test/bigo_site_test.dart` | `tests` | low | 0 | 154 | accept |
| D | `test/bilibili_danmaku_protocol_test.dart` | `tests` | low | 0 | 268 | accept |
| D | `test/bilibili_login_lifecycle_test.dart` | `tests` | low | 0 | 472 | accept |
| D | `test/bilibili_login_qr_code_test.dart` | `tests` | low | 0 | 25 | accept |
| D | `test/bilibili_play_quality_test.dart` | `tests` | low | 0 | 83 | accept |
| D | `test/bilibili_recommend_test.dart` | `tests` | low | 0 | 101 | accept |
| D | `test/bottom_control_surface_test.dart` | `tests` | low | 0 | 83 | accept |
| D | `test/bounded_async_pool_test.dart` | `tests` | low | 0 | 57 | accept |
| D | `test/bounded_navigation_scroll_test.dart` | `tests` | low | 0 | 115 | accept |
| D | `test/brightness_platform_boundary_test.dart` | `tests` | low | 0 | 51 | accept |
| D | `test/cache_controller_scope_test.dart` | `tests` | low | 0 | 160 | accept |
| D | `test/cache_data_settings_page_test.dart` | `tests` | low | 0 | 227 | accept |
| D | `test/cancellable_http_connections_test.dart` | `tests` | low | 0 | 332 | accept |
| D | `test/cc_audience_metric_test.dart` | `tests` | low | 0 | 51 | accept |
| D | `test/cc_catalog_test.dart` | `tests` | low | 0 | 207 | accept |
| D | `test/cc_category_controller_test.dart` | `tests` | low | 0 | 222 | accept |
| D | `test/cc_category_fallback_test.dart` | `tests` | low | 0 | 22 | accept |
| D | `test/cc_category_rooms_test.dart` | `tests` | low | 0 | 157 | accept |
| D | `test/cc_official_entry_navigation_test.dart` | `tests` | low | 0 | 147 | accept |
| D | `test/cc_quality_parser_test.dart` | `tests` | low | 0 | 56 | accept |
| D | `test/common/styles/dynamic_color_adapter_test.dart` | `tests` | low | 0 | 122 | accept |
| D | `test/common/styles/ui_dependency_compatibility_test.dart` | `tests` | low | 0 | 77 | accept |
| D | `test/compact_danmaku_metrics_test.dart` | `tests` | low | 0 | 77 | accept |
| D | `test/content_first_panel_layout_test.dart` | `tests` | low | 0 | 50 | accept |
| D | `test/control_hover_region_test.dart` | `tests` | low | 0 | 118 | accept |
| A | `test/core/config/cookie_settings_test.dart` | `tests` | low | 131 | 0 | accept |
| A | `test/core/config/float_window_geometry_test.dart` | `tests` | low | 59 | 0 | accept |
| A | `test/core/i18n_bundle_test.dart` | `tests` | low | 109 | 0 | accept |
| A | `test/core/network/site_transport_failure_test.dart` | `tests` | low | 103 | 0 | accept |
| A | `test/core/platform/windows_system_proxy_test.dart` | `tests` | low | 35 | 0 | accept |
| A | `test/core/player/audio_only_mode_policy_test.dart` | `tests` | low | 23 | 0 | accept |
| A | `test/core/player/compact_playback_progress_test.dart` | `tests` | low | 100 | 0 | accept |
| A | `test/core/player/dummy_video_policy_test.dart` | `tests` | low | 26 | 0 | accept |
| A | `test/core/player/kernel_floating_window_presenter_test.dart` | `tests` | low | 32 | 0 | accept |
| A | `test/core/player/media_kit_source_properties_test.dart` | `tests` | low | 86 | 0 | accept |
| A | `test/core/player/owned_input_recipe_test.dart` | `tests` | low | 34 | 0 | accept |
| A | `test/core/player/playback_lifecycle_coordinator_test.dart` | `tests` | low | 108 | 0 | accept |
| A | `test/core/player/playback_proxy_policy_test.dart` | `tests` | low | 45 | 0 | accept |
| A | `test/core/player/super_resolution_chain_test.dart` | `tests` | low | 94 | 0 | accept |
| A | `test/core/release/release_asset_urls_test.dart` | `tests` | low | 68 | 0 | accept |
| A | `test/core/theme/app_canvas_scope_test.dart` | `tests` | low | 43 | 0 | accept |
| A | `test/core/utils/live_quality_display_test.dart` | `tests` | low | 104 | 0 | accept |
| A | `test/core/widgets/fitting_sheet_body_test.dart` | `tests` | low | 76 | 0 | accept |
| D | `test/cover_metric_badge_test.dart` | `tests` | low | 0 | 23 | accept |
| D | `test/dailymotion_catalog_migration_test.dart` | `tests` | low | 0 | 60 | accept |
| D | `test/dailymotion_site_test.dart` | `tests` | low | 0 | 169 | accept |
| D | `test/danmaku_arrival_counter_test.dart` | `tests` | low | 0 | 33 | accept |
| D | `test/danmaku_controller_lifecycle_test.dart` | `tests` | low | 0 | 318 | accept |
| D | `test/danmaku_frozen_filter_test.dart` | `tests` | low | 0 | 106 | accept |
| D | `test/danmaku_keyboard_focus_test.dart` | `tests` | low | 0 | 101 | accept |
| D | `test/danmaku_list_resume_test.dart` | `tests` | low | 0 | 204 | accept |
| D | `test/danmaku_list_scroll_policy_test.dart` | `tests` | low | 0 | 121 | accept |
| D | `test/danmaku_message_actions_test.dart` | `tests` | low | 0 | 343 | accept |
| D | `test/danmaku_message_gate_test.dart` | `tests` | low | 0 | 51 | accept |
| D | `test/danmaku_presentation_recovery_test.dart` | `tests` | low | 0 | 77 | accept |
| D | `test/danmaku_refresh_rate_policy_test.dart` | `tests` | low | 0 | 66 | accept |
| D | `test/danmaku_settings_controller_test.dart` | `tests` | low | 0 | 205 | accept |
| D | `test/danmaku_settings_surface_test.dart` | `tests` | low | 0 | 426 | accept |
| D | `test/danmaku_similarity_filter_test.dart` | `tests` | low | 0 | 64 | accept |
| D | `test/danmaku_viewing_preset_test.dart` | `tests` | low | 0 | 153 | accept |
| D | `test/debug_log_buffer_test.dart` | `tests` | low | 0 | 38 | accept |
| D | `test/deferred_timer_settings_test.dart` | `tests` | low | 0 | 117 | accept |
| D | `test/desktop_scroll_behavior_test.dart` | `tests` | low | 0 | 35 | accept |
| D | `test/desktop_tray_menu_transaction_test.dart` | `tests` | low | 0 | 65 | accept |
| D | `test/discovery_scope_owners_test.dart` | `tests` | low | 0 | 242 | accept |
| D | `test/display_mode_service_test.dart` | `tests` | low | 0 | 75 | accept |
| A | `test/domains/live/area_display_config_test.dart` | `tests` | low | 41 | 0 | accept |
| A | `test/domains/live/audio_only_presentation_test.dart` | `tests` | low | 120 | 0 | accept |
| A | `test/domains/live/dummy_video_cover_test.dart` | `tests` | low | 102 | 0 | accept |
| A | `test/domains/live/favorite_refresh_failure_summary_test.dart` | `tests` | low | 27 | 0 | accept |
| A | `test/domains/live/ingest_source_interceptor_test.dart` | `tests` | low | 135 | 0 | accept |
| A | `test/domains/live/live_input_playback_binding_test.dart` | `tests` | low | 34 | 0 | accept |
| A | `test/domains/live/loopback_relay_session_cookie_test.dart` | `tests` | low | 98 | 0 | accept |
| A | `test/domains/live/picture_cover_test.dart` | `tests` | low | 30 | 0 | accept |
| A | `test/domains/live/playback_header_resolver_test.dart` | `tests` | low | 57 | 0 | accept |
| A | `test/domains/live/playback_ingest_needs_test.dart` | `tests` | low | 40 | 0 | accept |
| A | `test/domains/live/playback_manifest_probe_test.dart` | `tests` | low | 90 | 0 | accept |
| A | `test/domains/live/playback_source_refresh_test.dart` | `tests` | low | 293 | 0 | accept |
| A | `test/domains/live/stream_metadata_failure_key_test.dart` | `tests` | low | 35 | 0 | accept |
| A | `test/domains/live/unknown_room_status_message_test.dart` | `tests` | low | 42 | 0 | accept |
| A | `test/domains/live/video_key_bindings_test.dart` | `tests` | low | 66 | 0 | accept |
| A | `test/domains/recorder/local_player_small_window_test.dart` | `tests` | low | 20 | 0 | accept |
| A | `test/domains/recorder/record_dir_permission_gate_test.dart` | `tests` | low | 49 | 0 | accept |
| A | `test/domains/recorder/record_input_relay_facts_test.dart` | `tests` | low | 75 | 0 | accept |
| A | `test/domains/recorder/recording_resume_test.dart` | `tests` | low | 35 | 0 | accept |
| A | `test/domains/wallpaper/wallpaper_canvas_transparency_test.dart` | `tests` | low | 178 | 0 | accept |
| A | `test/domains/wallpaper/wallpaper_catalog_labels_test.dart` | `tests` | low | 88 | 0 | accept |
| D | `test/douyin_audience_metric_test.dart` | `tests` | low | 0 | 54 | accept |
| D | `test/douyin_danmaku_protocol_test.dart` | `tests` | low | 0 | 106 | accept |
| D | `test/douyin_parser_test.dart` | `tests` | low | 0 | 109 | accept |
| D | `test/douyin_playback_parser_test.dart` | `tests` | low | 0 | 178 | accept |
| D | `test/douyin_search_test.dart` | `tests` | low | 0 | 53 | accept |
| D | `test/douyu_danmaku_protocol_test.dart` | `tests` | low | 0 | 106 | accept |
| D | `test/douyu_playback_parser_test.dart` | `tests` | low | 0 | 207 | accept |
| D | `test/douyu_quality_ack_test.dart` | `tests` | low | 0 | 227 | accept |
| D | `test/download_apk_dialog_test.dart` | `tests` | low | 0 | 577 | accept |
| D | `test/engine_fallback_manager_test.dart` | `tests` | low | 0 | 43 | accept |
| D | `test/epg_channel_match_cache_test.dart` | `tests` | low | 0 | 25 | accept |
| D | `test/epg_import_manager_test.dart` | `tests` | low | 0 | 562 | accept |
| D | `test/epg_source_identity_test.dart` | `tests` | low | 0 | 753 | accept |
| D | `test/favorite_area_identity_test.dart` | `tests` | low | 0 | 240 | accept |
| D | `test/favorite_areas_page_test.dart` | `tests` | low | 0 | 252 | accept |
| D | `test/favorite_pull_refresh_test.dart` | `tests` | low | 0 | 64 | accept |
| D | `test/favorite_refresh_lifecycle_test.dart` | `tests` | low | 0 | 460 | accept |
| D | `test/favorite_room_validity_test.dart` | `tests` | low | 0 | 26 | accept |
| D | `test/favorite_startup_policy_test.dart` | `tests` | low | 0 | 179 | accept |
| D | `test/favorite_tag_strip_test.dart` | `tests` | low | 0 | 90 | accept |
| D | `test/fc2_control_session_test.dart` | `tests` | low | 0 | 143 | accept |
| D | `test/fc2live_catalog_migration_test.dart` | `tests` | low | 0 | 57 | accept |
| D | `test/fc2live_site_test.dart` | `tests` | low | 0 | 216 | accept |
| A | `test/features/settings/player_guide_labels_test.dart` | `tests` | low | 70 | 0 | accept |
| D | `test/ffmpeg_failure_classifier_test.dart` | `tests` | low | 0 | 196 | accept |
| D | `test/ffmpeg_flv_access_unit_stop_test.dart` | `tests` | low | 0 | 176 | accept |
| D | `test/ffmpeg_flv_diagnostics_test.dart` | `tests` | low | 0 | 78 | accept |
| D | `test/ffmpeg_flv_input_relay_test.dart` | `tests` | low | 0 | 254 | accept |
| D | `test/ffmpeg_hls_body_idle_test.dart` | `tests` | low | 0 | 252 | accept |
| D | `test/ffmpeg_hls_body_ownership_test.dart` | `tests` | low | 0 | 102 | accept |
| D | `test/ffmpeg_hls_connect_stop_test.dart` | `tests` | low | 0 | 118 | accept |
| D | `test/ffmpeg_hls_input_relay_test.dart` | `tests` | low | 0 | 721 | accept |
| D | `test/ffmpeg_hls_prefetch_integration_test.dart` | `tests` | low | 0 | 602 | accept |
| D | `test/ffmpeg_hls_request_ownership_test.dart` | `tests` | low | 0 | 64 | accept |
| D | `test/ffmpeg_hls_source_query_test.dart` | `tests` | low | 0 | 227 | accept |
| D | `test/ffmpeg_hls_staging_limits_test.dart` | `tests` | low | 0 | 227 | accept |
| D | `test/ffmpeg_input_drain_test.dart` | `tests` | low | 0 | 64 | accept |
| D | `test/ffmpeg_progress_time_test.dart` | `tests` | low | 0 | 17 | accept |
| D | `test/ffmpeg_record_command_test.dart` | `tests` | low | 0 | 198 | accept |
| D | `test/ffmpeg_scheduler_cancel_token_test.dart` | `tests` | low | 0 | 20 | accept |
| D | `test/ffmpeg_scheduler_lifecycle_test.dart` | `tests` | low | 0 | 127 | accept |
| D | `test/ffmpeg_terminal_evidence_test.dart` | `tests` | low | 0 | 191 | accept |
| D | `test/ffmpeg_tls_trust_store_test.dart` | `tests` | low | 0 | 16 | accept |
| D | `test/fijk_buffering_event_test.dart` | `tests` | low | 0 | 246 | accept |
| D | `test/file_utils_url_test.dart` | `tests` | low | 0 | 56 | accept |
| D | `test/firebase_auth_controller_lifecycle_test.dart` | `tests` | low | 0 | 287 | accept |
| D | `test/firebase_email_auth_lifecycle_test.dart` | `tests` | low | 0 | 366 | accept |
| D | `test/firebase_profile_page_test.dart` | `tests` | low | 0 | 270 | accept |
| D | `test/firebase_user_config_preview_test.dart` | `tests` | low | 0 | 355 | accept |
| D | `test/fixed_remote_page_lifecycle_test.dart` | `tests` | low | 0 | 331 | accept |
| D | `test/fixtures/bigo/README.md` | `tests` | low | 0 | 25 | accept |
| D | `test/fixtures/bigo/directory.json` | `tests` | low | 0 | 21 | accept |
| D | `test/fixtures/bigo/login-gate.json` | `tests` | low | 0 | 29 | accept |
| D | `test/fixtures/bigo/recommendations.json` | `tests` | low | 0 | 64 | accept |
| D | `test/fixtures/bigo/studio-login.json` | `tests` | low | 0 | 21 | accept |
| D | `test/fixtures/cc/README.md` | `tests` | low | 0 | 25 | accept |
| D | `test/fixtures/cc/dashen-games.json` | `tests` | low | 0 | 535 | accept |
| D | `test/fixtures/cc/dashen-live-config.json` | `tests` | low | 0 | 130 | accept |
| D | `test/fixtures/huajiao/README.md` | `tests` | low | 0 | 17 | accept |
| D | `test/fixtures/huajiao/broadcast.json` | `tests` | low | 0 | 36 | accept |
| D | `test/fixtures/huajiao/directory.json` | `tests` | low | 0 | 37 | accept |
| D | `test/fixtures/huajiao/empty-page.json` | `tests` | low | 0 | 13 | accept |
| D | `test/fixtures/huajiao/missing-broadcast.json` | `tests` | low | 0 | 11 | accept |
| D | `test/fixtures/kilakila/README.md` | `tests` | low | 0 | 24 | accept |
| D | `test/fixtures/kilakila/share-vectors.json` | `tests` | low | 0 | 168 | accept |
| D | `test/fixtures/niconico/README.md` | `tests` | low | 0 | 19 | accept |
| D | `test/fixtures/niconico/ended.json` | `tests` | low | 0 | 28 | accept |
| D | `test/fixtures/niconico/live.json` | `tests` | low | 0 | 28 | accept |
| D | `test/fixtures/niconico/region.json` | `tests` | low | 0 | 28 | accept |
| D | `test/fixtures/niconico/scheduled.json` | `tests` | low | 0 | 28 | accept |
| D | `test/fixtures/niconico/stream.json` | `tests` | low | 0 | 119 | accept |
| D | `test/fixtures/openrec/README.md` | `tests` | low | 0 | 33 | accept |
| D | `test/fixtures/openrec/channel-live.json` | `tests` | low | 0 | 60 | accept |
| D | `test/fixtures/openrec/channel-offline.json` | `tests` | low | 0 | 10 | accept |
| D | `test/fixtures/openrec/directory.json` | `tests` | low | 0 | 51 | accept |
| D | `test/fixtures/openrec/empty-page.json` | `tests` | low | 0 | 1 | accept |
| D | `test/fixtures/openrec/low-latency-master.m3u8` | `tests` | low | 0 | 4 | accept |
| D | `test/fixtures/openrec/master.m3u8` | `tests` | low | 0 | 17 | accept |
| D | `test/fixtures/openrec/media-playlist.m3u8` | `tests` | low | 0 | 20 | accept |
| D | `test/fixtures/openrec/movie.json` | `tests` | low | 0 | 49 | accept |
| D | `test/fixtures/openrec/public-master.m3u8` | `tests` | low | 0 | 5 | accept |
| D | `test/fixtures/picarto/README.md` | `tests` | low | 0 | 1 | accept |
| D | `test/fixtures/picarto/detail.json` | `tests` | low | 0 | 51 | accept |
| D | `test/fixtures/picarto/master.m3u8` | `tests` | low | 0 | 3 | accept |
| D | `test/fixtures/tls/README.md` | `tests` | low | 0 | 19 | accept |
| D | `test/fixtures/tls/localhost-cert.pem` | `tests` | low | 0 | 18 | accept |
| D | `test/fixtures/tls/localhost-key.pem` | `tests` | low | 0 | 28 | accept |
| D | `test/fixtures/tls/wrong-host-cert.pem` | `tests` | low | 0 | 18 | accept |
| D | `test/fixtures/tting/README.md` | `tests` | low | 0 | 23 | accept |
| D | `test/fixtures/tting/directory.json` | `tests` | low | 0 | 28 | accept |
| D | `test/fixtures/tting/profile.json` | `tests` | low | 0 | 19 | accept |
| D | `test/fixtures/tting/stream.json` | `tests` | low | 0 | 57 | accept |
| D | `test/fixtures/twitcasting/README.md` | `tests` | low | 0 | 11 | accept |
| D | `test/fixtures/twitcasting/categories.html` | `tests` | low | 0 | 1 | accept |
| D | `test/fixtures/twitcasting/directory.json` | `tests` | low | 0 | 30 | accept |
| D | `test/fixtures/twitcasting/live-stream.json` | `tests` | low | 0 | 13 | accept |
| D | `test/fixtures/twitcasting/offline-stream.json` | `tests` | low | 0 | 13 | accept |
| D | `test/fixtures/twitcasting/room.html` | `tests` | low | 0 | 1 | accept |
| D | `test/fixtures/weibo/README.md` | `tests` | low | 0 | 9 | accept |
| D | `test/fixtures/weibo/detail.json` | `tests` | low | 0 | 6 | accept |
| D | `test/fixtures/weibo/live-detail.json` | `tests` | low | 0 | 41 | accept |
| D | `test/fixtures/weibo/recommend.json` | `tests` | low | 0 | 21 | accept |
| D | `test/fixtures/xiaohongshu/ended.json` | `tests` | low | 0 | 33 | accept |
| D | `test/fixtures/xiaohongshu/live.json` | `tests` | low | 0 | 39 | accept |
| D | `test/fixtures/zhanqi/directory.json` | `tests` | low | 0 | 64 | accept |
| D | `test/fixtures/zhanqi/player-layout.json` | `tests` | low | 0 | 59 | accept |
| D | `test/fixtures/zhanqi/room.json` | `tests` | low | 0 | 20 | accept |
| D | `test/floating_status_lifecycle_test.dart` | `tests` | low | 0 | 134 | accept |
| D | `test/focus_rail_visibility_test.dart` | `tests` | low | 0 | 28 | accept |
| D | `test/font_family_manager_page_test.dart` | `tests` | low | 0 | 307 | accept |
| D | `test/font_settings_page_test.dart` | `tests` | low | 0 | 263 | accept |
| D | `test/font_storage_path_test.dart` | `tests` | low | 0 | 27 | accept |
| D | `test/frame_hash_timeline_test.dart` | `tests` | low | 0 | 70 | accept |
| D | `test/fullscreen_orientation_restore_test.dart` | `tests` | low | 0 | 38 | accept |
| D | `test/general_settings_refresh_rate_dialog_layout_test.dart` | `tests` | low | 0 | 460 | accept |
| D | `test/get_native_predictive_back_test.dart` | `tests` | low | 0 | 217 | accept |
| D | `test/get_overlay_context_test.dart` | `tests` | low | 0 | 67 | accept |
| D | `test/github_mirror_test.dart` | `tests` | low | 0 | 12 | accept |
| D | `test/goodgame_catalog_migration_test.dart` | `tests` | low | 0 | 58 | accept |
| D | `test/goodgame_danmaku_test.dart` | `tests` | low | 0 | 172 | accept |
| D | `test/goodgame_site_test.dart` | `tests` | low | 0 | 247 | accept |
| D | `test/history_metadata_test.dart` | `tests` | low | 0 | 143 | accept |
| D | `test/history_page_test.dart` | `tests` | low | 0 | 552 | accept |
| D | `test/hls_body_reader_test.dart` | `tests` | low | 0 | 61 | accept |
| D | `test/hls_capture_contract_test.dart` | `tests` | low | 0 | 201 | accept |
| D | `test/hls_daterange_test.dart` | `tests` | low | 0 | 251 | accept |
| D | `test/hls_http_body_metadata_test.dart` | `tests` | low | 0 | 119 | accept |
| D | `test/hls_low_latency_recording_test.dart` | `tests` | low | 0 | 187 | accept |
| D | `test/hls_master_selection_test.dart` | `tests` | low | 0 | 130 | accept |
| D | `test/hls_media_spool_test.dart` | `tests` | low | 0 | 74 | accept |
| D | `test/hls_prefetch_download_diagnostics_test.dart` | `tests` | low | 0 | 205 | accept |
| D | `test/hls_prefetch_plan_test.dart` | `tests` | low | 0 | 91 | accept |
| D | `test/hls_prefetch_pool_test.dart` | `tests` | low | 0 | 388 | accept |
| D | `test/hls_prefetch_preparation_test.dart` | `tests` | low | 0 | 317 | accept |
| D | `test/hls_prefetch_scheduler_test.dart` | `tests` | low | 0 | 503 | accept |
| D | `test/hls_refresh_coverage_test.dart` | `tests` | low | 0 | 175 | accept |
| D | `test/hls_relay_diagnostics_test.dart` | `tests` | low | 0 | 283 | accept |
| D | `test/hls_reload_cadence_test.dart` | `tests` | low | 0 | 126 | accept |
| D | `test/hls_retained_manifest_test.dart` | `tests` | low | 0 | 175 | accept |
| D | `test/hls_retained_window_test.dart` | `tests` | low | 0 | 210 | accept |
| D | `test/hls_runtime_cookies_test.dart` | `tests` | low | 0 | 249 | accept |
| D | `test/hls_selected_window_test.dart` | `tests` | low | 0 | 149 | accept |
| D | `test/hls_session_cookies_test.dart` | `tests` | low | 0 | 115 | accept |
| D | `test/hls_source_query_policy_test.dart` | `tests` | low | 0 | 91 | accept |
| D | `test/hls_upstream_client_test.dart` | `tests` | low | 0 | 330 | accept |
| D | `test/home_tablet_view_test.dart` | `tests` | low | 0 | 276 | accept |
| D | `test/http_error_diagnostic_test.dart` | `tests` | low | 0 | 93 | accept |
| D | `test/huajiao_api_test.dart` | `tests` | low | 0 | 525 | accept |
| D | `test/huajiao_application_test.dart` | `tests` | low | 0 | 626 | accept |
| D | `test/huajiao_catalog_migration_test.dart` | `tests` | low | 0 | 79 | accept |
| D | `test/huya_audience_metric_test.dart` | `tests` | low | 0 | 20 | accept |
| D | `test/huya_danmaku_protocol_test.dart` | `tests` | low | 0 | 211 | accept |
| D | `test/huya_message_board_test.dart` | `tests` | low | 0 | 118 | accept |
| D | `test/huya_play_url_test.dart` | `tests` | low | 0 | 651 | accept |
| D | `test/huya_transport_policy_test.dart` | `tests` | low | 0 | 125 | accept |
| D | `test/initial_services_policy_test.dart` | `tests` | low | 0 | 22 | accept |
| D | `test/inke_api_test.dart` | `tests` | low | 0 | 331 | accept |
| D | `test/inke_application_test.dart` | `tests` | low | 0 | 328 | accept |
| D | `test/inke_catalog_migration_test.dart` | `tests` | low | 0 | 198 | accept |
| D | `test/iptv_auto_mapping_test.dart` | `tests` | low | 0 | 369 | accept |
| D | `test/iptv_import_manager_test.dart` | `tests` | low | 0 | 798 | accept |
| D | `test/iptv_manage_page_test.dart` | `tests` | low | 0 | 310 | accept |
| D | `test/iptv_playback_quality_test.dart` | `tests` | low | 0 | 15 | accept |
| D | `test/iptv_playback_transaction_test.dart` | `tests` | low | 0 | 234 | accept |
| D | `test/iptv_programme_policy_test.dart` | `tests` | low | 0 | 306 | accept |
| D | `test/iptv_resource_load_gate_test.dart` | `tests` | low | 0 | 29 | accept |
| D | `test/iptv_schedule_dialog_test.dart` | `tests` | low | 0 | 348 | accept |
| D | `test/iptv_settings_page_test.dart` | `tests` | low | 0 | 815 | accept |
| D | `test/iptv_startup_policy_test.dart` | `tests` | low | 0 | 19 | accept |
| D | `test/jd_live_catalog_migration_test.dart` | `tests` | low | 0 | 50 | accept |
| D | `test/jd_live_site_test.dart` | `tests` | low | 0 | 166 | accept |
| D | `test/kick_danmaku_test.dart` | `tests` | low | 0 | 207 | accept |
| D | `test/kilakila_api_test.dart` | `tests` | low | 0 | 507 | accept |
| D | `test/kilakila_application_test.dart` | `tests` | low | 0 | 475 | accept |
| D | `test/kilakila_catalog_migration_test.dart` | `tests` | low | 0 | 145 | accept |
| D | `test/kilakila_directory_contract_test.dart` | `tests` | low | 0 | 83 | accept |
| D | `test/kilakila_link_test.dart` | `tests` | low | 0 | 171 | accept |
| D | `test/kilakila_owner_test.dart` | `tests` | low | 0 | 213 | accept |
| D | `test/known_room_link_action_test.dart` | `tests` | low | 0 | 425 | accept |
| D | `test/kuaishou_danmaku_test.dart` | `tests` | low | 0 | 110 | accept |
| D | `test/kuaishou_playback_parser_test.dart` | `tests` | low | 0 | 54 | accept |
| D | `test/kugou_live_catalog_migration_test.dart` | `tests` | low | 0 | 50 | accept |
| D | `test/kugou_live_site_test.dart` | `tests` | low | 0 | 250 | accept |
| D | `test/langlive_site_test.dart` | `tests` | low | 0 | 164 | accept |
| D | `test/latest_async_value_queue_test.dart` | `tests` | low | 0 | 75 | accept |
| D | `test/layout_paging_transaction_test.dart` | `tests` | low | 0 | 309 | accept |
| D | `test/list_notifier_lifecycle_test.dart` | `tests` | low | 0 | 28 | accept |
| D | `test/live_audio_handler_ownership_test.dart` | `tests` | low | 0 | 435 | accept |
| D | `test/live_audio_metadata_test.dart` | `tests` | low | 0 | 18 | accept |
| D | `test/live_buffer_policy_test.dart` | `tests` | low | 0 | 54 | accept |
| D | `test/live_directory_controller_test.dart` | `tests` | low | 0 | 1116 | accept |
| D | `test/live_dlna_dialog_test.dart` | `tests` | low | 0 | 458 | accept |
| D | `test/live_owned_input_resolution_test.dart` | `tests` | low | 0 | 84 | accept |
| D | `test/live_play_back_scope_test.dart` | `tests` | low | 0 | 99 | accept |
| D | `test/live_play_navigation_ui_test.dart` | `tests` | low | 0 | 324 | accept |
| D | `test/live_play_normal_layout_test.dart` | `tests` | low | 0 | 334 | accept |
| D | `test/live_play_state_test.dart` | `tests` | low | 0 | 33 | accept |
| D | `test/live_play_unknown_metadata_test.dart` | `tests` | low | 0 | 130 | accept |
| D | `test/live_quality_label_test.dart` | `tests` | low | 0 | 31 | accept |
| D | `test/live_record_task_persistence_test.dart` | `tests` | low | 0 | 315 | accept |
| D | `test/live_room_audience_metric_test.dart` | `tests` | low | 0 | 259 | accept |
| D | `test/live_room_error_fallback_test.dart` | `tests` | low | 0 | 39 | accept |
| D | `test/live_room_external_open_test.dart` | `tests` | low | 0 | 152 | accept |
| D | `test/live_room_status_test.dart` | `tests` | low | 0 | 73 | accept |
| D | `test/live_short_link_io_test.dart` | `tests` | low | 0 | 84 | accept |
| D | `test/live_short_link_test.dart` | `tests` | low | 0 | 270 | accept |
| D | `test/live_stream_geometry_hint_test.dart` | `tests` | low | 0 | 170 | accept |
| D | `test/live_url_tool_parser_test.dart` | `tests` | low | 0 | 86 | accept |
| D | `test/loading_style_settings_page_test.dart` | `tests` | low | 0 | 134 | accept |
| D | `test/local_interaction_controller_test.dart` | `tests` | low | 0 | 82 | accept |
| D | `test/local_interaction_settings_page_test.dart` | `tests` | low | 0 | 267 | accept |
| D | `test/local_message_delivery_queue_test.dart` | `tests` | low | 0 | 48 | accept |
| D | `test/local_reactive_refresh_test.dart` | `tests` | low | 0 | 116 | accept |
| D | `test/local_refresh_lifecycle_test.dart` | `tests` | low | 0 | 509 | accept |
| D | `test/log_browser_page_test.dart` | `tests` | low | 0 | 131 | accept |
| D | `test/log_controller_transaction_test.dart` | `tests` | low | 0 | 137 | accept |
| D | `test/look_live_catalog_migration_test.dart` | `tests` | low | 0 | 47 | accept |
| D | `test/look_live_site_test.dart` | `tests` | low | 0 | 196 | accept |
| D | `test/m3u_parser_test.dart` | `tests` | low | 0 | 359 | accept |
| D | `test/media_kit_buffering_state_test.dart` | `tests` | low | 0 | 304 | accept |
| D | `test/media_packet_timeline_test.dart` | `tests` | low | 0 | 136 | accept |
| D | `test/missevan_adapter_test.dart` | `tests` | low | 0 | 681 | accept |
| D | `test/missevan_catalog_migration_test.dart` | `tests` | low | 0 | 138 | accept |
| D | `test/mobile_video_frame_test.dart` | `tests` | low | 0 | 203 | accept |
| D | `test/multiview_frame_watchdog_test.dart` | `tests` | low | 0 | 122 | accept |
| D | `test/multiview_fullscreen_surface_test.dart` | `tests` | low | 0 | 53 | accept |
| D | `test/multiview_owned_input_test.dart` | `tests` | low | 0 | 650 | accept |
| D | `test/multiview_room_picker_test.dart` | `tests` | low | 0 | 38 | accept |
| D | `test/multiview_test.dart` | `tests` | low | 0 | 1692 | accept |
| D | `test/navigation_settings_page_test.dart` | `tests` | low | 0 | 186 | accept |
| D | `test/network_image_url_test.dart` | `tests` | low | 0 | 36 | accept |
| D | `test/network_proxy_settings_page_test.dart` | `tests` | low | 0 | 212 | accept |
| D | `test/niconico_api_test.dart` | `tests` | low | 0 | 225 | accept |
| D | `test/niconico_application_test.dart` | `tests` | low | 0 | 199 | accept |
| D | `test/niconico_capture_contract_test.dart` | `tests` | low | 0 | 54 | accept |
| D | `test/niconico_catalog_migration_test.dart` | `tests` | low | 0 | 71 | accept |
| D | `test/niconico_directory_layout_test.dart` | `tests` | low | 0 | 110 | accept |
| D | `test/niconico_directory_test.dart` | `tests` | low | 0 | 313 | accept |
| D | `test/niconico_hls_input_test.dart` | `tests` | low | 0 | 446 | accept |
| D | `test/niconico_master_reader_test.dart` | `tests` | low | 0 | 102 | accept |
| D | `test/niconico_playback_input_test.dart` | `tests` | low | 0 | 206 | accept |
| D | `test/niconico_quality_catalog_test.dart` | `tests` | low | 0 | 245 | accept |
| D | `test/niconico_session_test.dart` | `tests` | low | 0 | 417 | accept |
| D | `test/niconico_site_test.dart` | `tests` | low | 0 | 173 | accept |
| D | `test/niconico_stream_test.dart` | `tests` | low | 0 | 142 | accept |
| D | `test/nimotv_catalog_migration_test.dart` | `tests` | low | 0 | 50 | accept |
| D | `test/nimotv_site_test.dart` | `tests` | low | 0 | 199 | accept |
| D | `test/not_living_video_widget_layout_test.dart` | `tests` | low | 0 | 126 | accept |
| D | `test/openrec_api_test.dart` | `tests` | low | 0 | 467 | accept |
| D | `test/openrec_application_test.dart` | `tests` | low | 0 | 406 | accept |
| D | `test/openrec_catalog_migration_test.dart` | `tests` | low | 0 | 87 | accept |
| D | `test/openrec_hls_test.dart` | `tests` | low | 0 | 160 | accept |
| D | `test/owned_line_selector_test.dart` | `tests` | low | 0 | 83 | accept |
| D | `test/owned_record_input_test.dart` | `tests` | low | 0 | 399 | accept |
| D | `test/page_settings_boundary_test.dart` | `tests` | low | 0 | 103 | accept |
| D | `test/page_settings_dialog_layout_test.dart` | `tests` | low | 0 | 184 | accept |
| D | `test/page_size_transaction_test.dart` | `tests` | low | 0 | 252 | accept |
| D | `test/pandalive_catalog_migration_test.dart` | `tests` | low | 0 | 50 | accept |
| D | `test/pandalive_native_search_test.dart` | `tests` | low | 0 | 181 | accept |
| D | `test/pandalive_site_test.dart` | `tests` | low | 0 | 217 | accept |
| D | `test/picarto_adapter_test.dart` | `tests` | low | 0 | 693 | accept |
| D | `test/picarto_catalog_migration_test.dart` | `tests` | low | 0 | 84 | accept |
| D | `test/pip_danmaku_preview_test.dart` | `tests` | low | 0 | 504 | accept |
| D | `test/platform_response_lifecycle_test.dart` | `tests` | low | 0 | 414 | accept |
| D | `test/platform_settings_page_test.dart` | `tests` | low | 0 | 307 | accept |
| D | `test/platform_signing_utils_test.dart` | `tests` | low | 0 | 98 | accept |
| D | `test/play_other_history_test.dart` | `tests` | low | 0 | 9 | accept |
| D | `test/play_quality_label_test.dart` | `tests` | low | 0 | 119 | accept |
| D | `test/playback_failure_overlay_test.dart` | `tests` | low | 0 | 85 | accept |
| D | `test/playback_header_resolver_test.dart` | `tests` | low | 0 | 135 | accept |
| D | `test/playback_lifecycle_coordinator_test.dart` | `tests` | low | 0 | 195 | accept |
| D | `test/playback_owned_input_test.dart` | `tests` | low | 0 | 313 | accept |
| D | `test/playback_source_transport_test.dart` | `tests` | low | 0 | 334 | accept |
| D | `test/player_control_hover_test.dart` | `tests` | low | 0 | 107 | accept |
| D | `test/player_error_classifier_test.dart` | `tests` | low | 0 | 166 | accept |
| D | `test/player_error_recovery_test.dart` | `tests` | low | 0 | 3797 | accept |
| D | `test/player_kernel_settings_page_test.dart` | `tests` | low | 0 | 262 | accept |
| D | `test/player_load_fence_test.dart` | `tests` | low | 0 | 94 | accept |
| D | `test/player_owned_source_test.dart` | `tests` | low | 0 | 397 | accept |
| D | `test/player_settings_controller_test.dart` | `tests` | low | 0 | 282 | accept |
| D | `test/player_source_query_metadata_test.dart` | `tests` | low | 0 | 77 | accept |
| D | `test/popkontv_catalog_migration_test.dart` | `tests` | low | 0 | 50 | accept |
| D | `test/popkontv_site_test.dart` | `tests` | low | 0 | 243 | accept |
| D | `test/popular_audience_ranking_test.dart` | `tests` | low | 0 | 61 | accept |
| D | `test/popular_grid_natural_rows_test.dart` | `tests` | low | 0 | 134 | accept |
| D | `test/portrait_fullscreen_interaction_test.dart` | `tests` | low | 0 | 177 | accept |
| D | `test/portrait_playback_picker_dialog_test.dart` | `tests` | low | 0 | 195 | accept |
| D | `test/portrait_room_transition_test.dart` | `tests` | low | 0 | 231 | accept |
| D | `test/portrait_settings_dialog_layout_test.dart` | `tests` | low | 0 | 227 | accept |
| D | `test/portrait_stream_support_test.dart` | `tests` | low | 0 | 537 | accept |
| D | `test/proxy_routing_test.dart` | `tests` | low | 0 | 42 | accept |
| D | `test/proxy_settings_boundary_test.dart` | `tests` | low | 0 | 99 | accept |
| D | `test/pure_live_route_scroll_scope_test.dart` | `tests` | low | 0 | 91 | accept |
| D | `test/quality_discovery_cancellation_test.dart` | `tests` | low | 0 | 379 | accept |
| D | `test/race_http_test.dart` | `tests` | low | 0 | 51 | accept |
| D | `test/record_action_button_dialog_test.dart` | `tests` | low | 0 | 235 | accept |
| D | `test/record_action_content_test.dart` | `tests` | low | 0 | 36 | accept |
| D | `test/record_source_query_metadata_test.dart` | `tests` | low | 0 | 289 | accept |
| D | `test/recorder_background_service_test.dart` | `tests` | low | 0 | 187 | accept |
| D | `test/recorder_continuation_policy_test.dart` | `tests` | low | 0 | 182 | accept |
| D | `test/recorder_lease_lifecycle_test.dart` | `tests` | low | 0 | 437 | accept |
| D | `test/recorder_output_lifecycle_test.dart` | `tests` | low | 0 | 534 | accept |
| D | `test/recorder_page_test.dart` | `tests` | low | 0 | 290 | accept |
| D | `test/recorder_poll_lifecycle_test.dart` | `tests` | low | 0 | 380 | accept |
| D | `test/recorder_proxy_routing_test.dart` | `tests` | low | 0 | 67 | accept |
| D | `test/recorder_scroll_boundary_test.dart` | `tests` | low | 0 | 109 | accept |
| D | `test/recorder_settings_page_test.dart` | `tests` | low | 0 | 417 | accept |
| D | `test/recorder_settings_persistence_test.dart` | `tests` | low | 0 | 236 | accept |
| D | `test/recorder_storage_policy_test.dart` | `tests` | low | 0 | 238 | accept |
| D | `test/recorder_stream_resolver_test.dart` | `tests` | low | 0 | 382 | accept |
| D | `test/recorder_task_ordering_test.dart` | `tests` | low | 0 | 75 | accept |
| D | `test/recorder_user_intent_test.dart` | `tests` | low | 0 | 629 | accept |
| D | `test/recording_clock_probe_support_test.dart` | `tests` | low | 0 | 35 | accept |
| D | `test/recording_output_metrics_test.dart` | `tests` | low | 0 | 168 | accept |
| D | `test/recording_platform_contract_test.dart` | `tests` | low | 0 | 68 | accept |
| D | `test/recording_segment_clock_test.dart` | `tests` | low | 0 | 142 | accept |
| D | `test/refresh_config_controller_test.dart` | `tests` | low | 0 | 64 | accept |
| D | `test/refresh_indicator_layout_test.dart` | `tests` | low | 0 | 162 | accept |
| D | `test/refresh_settings_dialog_layout_test.dart` | `tests` | low | 0 | 144 | accept |
| D | `test/repeated_danmaku_filter_test.dart` | `tests` | low | 0 | 73 | accept |
| D | `test/resolutions_row_layout_test.dart` | `tests` | low | 0 | 192 | accept |
| D | `test/room_card_layout_metrics_test.dart` | `tests` | low | 0 | 48 | accept |
| D | `test/room_card_settings_controller_test.dart` | `tests` | low | 0 | 151 | accept |
| D | `test/room_card_settings_page_test.dart` | `tests` | low | 0 | 186 | accept |
| D | `test/room_card_tag_assignment_test.dart` | `tests` | low | 0 | 477 | accept |
| D | `test/room_external_opener_test.dart` | `tests` | low | 0 | 325 | accept |
| D | `test/room_timer_dialog_test.dart` | `tests` | low | 0 | 215 | accept |
| D | `test/room_volume_dialog_test.dart` | `tests` | low | 0 | 326 | accept |
| D | `test/rumble_catalog_migration_test.dart` | `tests` | low | 0 | 59 | accept |
| D | `test/rumble_site_test.dart` | `tests` | low | 0 | 196 | accept |
| D | `test/rx_stream_resubscribe_test.dart` | `tests` | low | 0 | 59 | accept |
| D | `test/scan_code_page_test.dart` | `tests` | low | 0 | 413 | accept |
| D | `test/search_lifecycle_test.dart` | `tests` | low | 0 | 62 | accept |
| D | `test/search_page_layout_test.dart` | `tests` | low | 0 | 357 | accept |
| D | `test/search_ranking_test.dart` | `tests` | low | 0 | 153 | accept |
| D | `test/search_request_cancellation_test.dart` | `tests` | low | 0 | 594 | accept |
| D | `test/search_scroll_policy_test.dart` | `tests` | low | 0 | 58 | accept |
| D | `test/search_webview2_missing_dialog_test.dart` | `tests` | low | 0 | 120 | accept |
| D | `test/server_all_page_lifecycle_test.dart` | `tests` | low | 0 | 366 | accept |
| D | `test/settings_page_layout_test.dart` | `tests` | low | 0 | 153 | accept |
| D | `test/settings_service_lifecycle_test.dart` | `tests` | low | 0 | 52 | accept |
| D | `test/settings_upgrade_migration_test.dart` | `tests` | low | 0 | 137 | accept |
| D | `test/seventeenlive_public_catalog_test.dart` | `tests` | low | 0 | 176 | accept |
| D | `test/share_command_handler_test.dart` | `tests` | low | 0 | 273 | accept |
| D | `test/share_command_import_dialog_test.dart` | `tests` | low | 0 | 123 | accept |
| A | `test/shared/platforms/acfun_protobuf_test.dart` | `tests` | low | 81 | 0 | accept |
| A | `test/shared/platforms/bigo_login_wall_test.dart` | `tests` | low | 102 | 0 | accept |
| A | `test/shared/platforms/huya_headline_panel_test.dart` | `tests` | low | 88 | 0 | accept |
| A | `test/shared/platforms/live_stream_facts_test.dart` | `tests` | low | 221 | 0 | accept |
| A | `test/shared/platforms/missevan_danmaku_session_test.dart` | `tests` | low | 27 | 0 | accept |
| A | `test/shared/platforms/sixroom_danmaku_servers_test.dart` | `tests` | low | 96 | 0 | accept |
| A | `test/shared/platforms/xiaohongshu_link_test.dart` | `tests` | low | 46 | 0 | accept |
| D | `test/shared_media_intake_test.dart` | `tests` | low | 0 | 321 | accept |
| D | `test/shared_media_temp_cleanup_test.dart` | `tests` | low | 0 | 90 | accept |
| D | `test/shield_management_page_test.dart` | `tests` | low | 0 | 366 | accept |
| D | `test/shopeelive_catalog_migration_test.dart` | `tests` | low | 0 | 50 | accept |
| D | `test/shopeelive_site_test.dart` | `tests` | low | 0 | 185 | accept |
| D | `test/sites_logo_lookup_test.dart` | `tests` | low | 0 | 17 | accept |
| D | `test/sites_test.dart` | `tests` | low | 0 | 60 | accept |
| D | `test/sixroom_catalog_migration_test.dart` | `tests` | low | 0 | 50 | accept |
| D | `test/sixroom_site_test.dart` | `tests` | low | 0 | 258 | accept |
| D | `test/soop_danmaku_endpoint_test.dart` | `tests` | low | 0 | 41 | accept |
| D | `test/soop_danmaku_test.dart` | `tests` | low | 0 | 57 | accept |
| D | `test/soop_platform_test.dart` | `tests` | low | 0 | 62 | accept |
| D | `test/stable_video_layer_test.dart` | `tests` | low | 0 | 83 | accept |
| D | `test/startup_controller_transaction_test.dart` | `tests` | low | 0 | 202 | accept |
| D | `test/steam_broadcast_catalog_migration_test.dart` | `tests` | low | 0 | 56 | accept |
| D | `test/steam_broadcast_site_test.dart` | `tests` | low | 0 | 146 | accept |
| D | `test/stream_selection_controller_test.dart` | `tests` | low | 0 | 1071 | accept |
| D | `test/super_chat_expiry_policy_test.dart` | `tests` | low | 0 | 43 | accept |
| D | `test/super_chat_page_test.dart` | `tests` | low | 0 | 216 | accept |
| D | `test/support/owned_source_test_player.dart` | `tests` | low | 0 | 203 | accept |
| D | `test/support/toolbox_test_site.dart` | `tests` | low | 0 | 45 | accept |
| D | `test/support/weibo_application_fixture.dart` | `tests` | low | 0 | 59 | accept |
| D | `test/tag_management_page_test.dart` | `tests` | low | 0 | 544 | accept |
| D | `test/taobao_live_catalog_migration_test.dart` | `tests` | low | 0 | 50 | accept |
| D | `test/taobao_live_site_test.dart` | `tests` | low | 0 | 200 | accept |
| D | `test/theme_font_resolution_test.dart` | `tests` | low | 0 | 31 | accept |
| D | `test/theme_settings_boundary_test.dart` | `tests` | low | 0 | 174 | accept |
| D | `test/theme_spacing_dialog_layout_test.dart` | `tests` | low | 0 | 262 | accept |
| D | `test/toolbox_action_test.dart` | `tests` | low | 0 | 118 | accept |
| D | `test/toolbox_clipboard_test.dart` | `tests` | low | 0 | 268 | accept |
| D | `test/toolbox_direct_link_flow_test.dart` | `tests` | low | 0 | 268 | accept |
| D | `test/toolbox_link_detection_test.dart` | `tests` | low | 0 | 57 | accept |
| D | `test/toolbox_workflow_widget_test.dart` | `tests` | low | 0 | 306 | accept |
| D | `test/transactional_page_refresh_test.dart` | `tests` | low | 0 | 143 | accept |
| D | `test/translation_contract_test.dart` | `tests` | low | 0 | 20 | accept |
| D | `test/tting_api_test.dart` | `tests` | low | 0 | 282 | accept |
| D | `test/tting_application_test.dart` | `tests` | low | 0 | 386 | accept |
| D | `test/tting_catalog_migration_test.dart` | `tests` | low | 0 | 76 | accept |
| D | `test/tting_hls_admission_summary_test.dart` | `tests` | low | 0 | 50 | accept |
| D | `test/twitcasting_adapter_test.dart` | `tests` | low | 0 | 532 | accept |
| D | `test/twitcasting_catalog_migration_test.dart` | `tests` | low | 0 | 86 | accept |
| D | `test/twitcasting_directory_paging_test.dart` | `tests` | low | 0 | 164 | accept |
| D | `test/twitch_danmaku_protocol_test.dart` | `tests` | low | 0 | 36 | accept |
| D | `test/twitch_directory_parser_test.dart` | `tests` | low | 0 | 126 | accept |
| D | `test/twitch_playback_parser_test.dart` | `tests` | low | 0 | 47 | accept |
| D | `test/twitch_web_integrity_test.dart` | `tests` | low | 0 | 57 | accept |
| D | `test/update_source_test.dart` | `tests` | low | 0 | 51 | accept |
| D | `test/user_directory_lifecycle_test.dart` | `tests` | low | 0 | 369 | accept |
| D | `test/user_management_action_lifecycle_test.dart` | `tests` | low | 0 | 496 | accept |
| D | `test/utils_alert_dialog_test.dart` | `tests` | low | 0 | 96 | accept |
| D | `test/utils_edit_text_dialog_test.dart` | `tests` | low | 0 | 105 | accept |
| D | `test/utils_exit_dialog_test.dart` | `tests` | low | 0 | 284 | accept |
| D | `test/utils_option_dialog_test.dart` | `tests` | low | 0 | 92 | accept |
| D | `test/version_controller_state_test.dart` | `tests` | low | 0 | 99 | accept |
| D | `test/version_page_layout_test.dart` | `tests` | low | 0 | 236 | accept |
| D | `test/video_keyboard_escape_test.dart` | `tests` | low | 0 | 416 | accept |
| D | `test/video_output_size_policy_test.dart` | `tests` | low | 0 | 80 | accept |
| D | `test/video_output_viewport_sizer_test.dart` | `tests` | low | 0 | 262 | accept |
| D | `test/video_processor_lifecycle_test.dart` | `tests` | low | 0 | 419 | accept |
| D | `test/video_processor_manifest_test.dart` | `tests` | low | 0 | 57 | accept |
| D | `test/video_processor_progress_test.dart` | `tests` | low | 0 | 62 | accept |
| D | `test/video_settings_resolution_dialog_test.dart` | `tests` | low | 0 | 797 | accept |
| D | `test/video_source_commit_listener_test.dart` | `tests` | low | 0 | 1317 | accept |
| D | `test/vkvideolive_catalog_migration_test.dart` | `tests` | low | 0 | 50 | accept |
| D | `test/vkvideolive_site_test.dart` | `tests` | low | 0 | 257 | accept |
| D | `test/volume_control_lifecycle_test.dart` | `tests` | low | 0 | 238 | accept |
| D | `test/web_search_lifecycle_test.dart` | `tests` | low | 0 | 406 | accept |
| D | `test/web_search_room_parser_test.dart` | `tests` | low | 0 | 148 | accept |
| D | `test/web_socket_util_test.dart` | `tests` | low | 0 | 302 | accept |
| D | `test/webdav_config_test.dart` | `tests` | low | 0 | 51 | accept |
| D | `test/webdav_directory_state_test.dart` | `tests` | low | 0 | 662 | accept |
| D | `test/webdav_help_page_test.dart` | `tests` | low | 0 | 169 | accept |
| D | `test/webdav_page_test.dart` | `tests` | low | 0 | 940 | accept |
| D | `test/webdav_service_test.dart` | `tests` | low | 0 | 103 | accept |
| D | `test/webdav_transfer_service_test.dart` | `tests` | low | 0 | 76 | accept |
| D | `test/weibo_api_test.dart` | `tests` | low | 0 | 290 | accept |
| D | `test/weibo_application_layout_test.dart` | `tests` | low | 0 | 254 | accept |
| D | `test/weibo_application_test.dart` | `tests` | low | 0 | 340 | accept |
| D | `test/weibo_catalog_migration_test.dart` | `tests` | low | 0 | 89 | accept |
| D | `test/weibo_share_normalization_test.dart` | `tests` | low | 0 | 54 | accept |
| D | `test/weibo_site_test.dart` | `tests` | low | 0 | 283 | accept |
| D | `test/window_size_settings_boundary_test.dart` | `tests` | low | 0 | 179 | accept |
| D | `test/windows_auto_start_command_test.dart` | `tests` | low | 0 | 24 | accept |
| D | `test/windows_fullscreen_transition_test.dart` | `tests` | low | 0 | 28 | accept |
| D | `test/windows_multi_instance_launcher_test.dart` | `tests` | low | 0 | 47 | accept |
| D | `test/windows_pip_geometry_test.dart` | `tests` | low | 0 | 102 | accept |
| D | `test/windows_pip_host_transaction_test.dart` | `tests` | low | 0 | 383 | accept |
| D | `test/windows_pip_presentation_test.dart` | `tests` | low | 0 | 177 | accept |
| D | `test/windows_title_bar_control_test.dart` | `tests` | low | 0 | 119 | accept |
| D | `test/windows_title_bar_overlay_test.dart` | `tests` | low | 0 | 54 | accept |
| D | `test/windows_title_bar_project_link_test.dart` | `tests` | low | 0 | 151 | accept |
| D | `test/xiaohongshu_application_test.dart` | `tests` | low | 0 | 385 | accept |
| D | `test/xiaohongshu_catalog_migration_test.dart` | `tests` | low | 0 | 71 | accept |
| D | `test/xiaohongshu_share_link_test.dart` | `tests` | low | 0 | 240 | accept |
| D | `test/xiaohongshu_share_test.dart` | `tests` | low | 0 | 234 | accept |
| D | `test/yy_protocol_test.dart` | `tests` | low | 0 | 256 | accept |
| D | `test/yy_site_parser_test.dart` | `tests` | low | 0 | 78 | accept |
| D | `test/yy_web_socket_channel_test.dart` | `tests` | low | 0 | 100 | accept |
| D | `test/zhanqi_api_test.dart` | `tests` | low | 0 | 286 | accept |
| D | `test/zhanqi_media_probe_test.dart` | `tests` | low | 0 | 158 | accept |
| D | `test/zhanqi_player_layout_test.dart` | `tests` | low | 0 | 218 | accept |
| D | `test/zhanqi_site_test.dart` | `tests` | low | 0 | 210 | accept |
| D | `third_party/media_kit_video/.gitignore` | `dependencies_and_vendored` | high | 0 | 33 | accept |
| D | `third_party/media_kit_video/.metadata` | `dependencies_and_vendored` | high | 0 | 42 | accept |
| D | `third_party/media_kit_video/CHANGELOG.md` | `dependencies_and_vendored` | high | 0 | 202 | accept |
| D | `third_party/media_kit_video/LICENSE` | `dependencies_and_vendored` | high | 0 | 21 | accept |
| D | `third_party/media_kit_video/PURELIVE_PATCH.md` | `dependencies_and_vendored` | high | 0 | 73 | accept |
| D | `third_party/media_kit_video/README.md` | `dependencies_and_vendored` | high | 0 | 11 | accept |
| D | `third_party/media_kit_video/analysis_options.yaml` | `dependencies_and_vendored` | high | 0 | 12 | accept |
| D | `third_party/media_kit_video/android/.gitignore` | `dependencies_and_vendored` | high | 0 | 9 | accept |
| D | `third_party/media_kit_video/android/build.gradle` | `dependencies_and_vendored` | high | 0 | 42 | accept |
| D | `third_party/media_kit_video/android/proguard-rules.pro` | `dependencies_and_vendored` | high | 0 | 3 | accept |
| D | `third_party/media_kit_video/android/settings.gradle` | `dependencies_and_vendored` | high | 0 | 1 | accept |
| D | `third_party/media_kit_video/android/src/main/AndroidManifest.xml` | `dependencies_and_vendored` | high | 0 | 1 | accept |
| D | `third_party/media_kit_video/android/src/main/java/com/alexmercerind/media_kit_video/MediaKitVideoPlugin.java` | `dependencies_and_vendored` | high | 0 | 89 | accept |
| D | `third_party/media_kit_video/android/src/main/java/com/alexmercerind/media_kit_video/TextureUpdateCallback.java` | `dependencies_and_vendored` | high | 0 | 5 | accept |
| D | `third_party/media_kit_video/android/src/main/java/com/alexmercerind/media_kit_video/Utils.java` | `dependencies_and_vendored` | high | 0 | 42 | accept |
| D | `third_party/media_kit_video/android/src/main/java/com/alexmercerind/media_kit_video/VideoOutput.java` | `dependencies_and_vendored` | high | 0 | 260 | accept |
| D | `third_party/media_kit_video/android/src/main/java/com/alexmercerind/media_kit_video/VideoOutputManager.java` | `dependencies_and_vendored` | high | 0 | 57 | accept |
| D | `third_party/media_kit_video/common/darwin/.gitignore` | `dependencies_and_vendored` | high | 0 | 1 | accept |
| D | `third_party/media_kit_video/common/darwin/Classes/plugin/MPVHelpers.swift` | `dependencies_and_vendored` | high | 0 | 37 | accept |
| D | `third_party/media_kit_video/common/darwin/Classes/plugin/MPVVideoOutParams.swift` | `dependencies_and_vendored` | high | 0 | 59 | accept |
| D | `third_party/media_kit_video/common/darwin/Classes/plugin/MediaKitVideoPlugin.swift` | `dependencies_and_vendored` | high | 0 | 176 | accept |
| D | `third_party/media_kit_video/common/darwin/Classes/plugin/ResizableTextureProtocol.swift` | `dependencies_and_vendored` | high | 0 | 14 | accept |
| D | `third_party/media_kit_video/common/darwin/Classes/plugin/SafeResizableTexture.swift` | `dependencies_and_vendored` | high | 0 | 54 | accept |
| D | `third_party/media_kit_video/common/darwin/Classes/plugin/SwappableObjectManager.swift` | `dependencies_and_vendored` | high | 0 | 108 | accept |
| D | `third_party/media_kit_video/common/darwin/Classes/plugin/TextureSW.swift` | `dependencies_and_vendored` | high | 0 | 161 | accept |
| D | `third_party/media_kit_video/common/darwin/Classes/plugin/TextureSWContext.swift` | `dependencies_and_vendored` | high | 0 | 40 | accept |
| D | `third_party/media_kit_video/common/darwin/Classes/plugin/UtilsProtocol.swift` | `dependencies_and_vendored` | high | 0 | 6 | accept |
| D | `third_party/media_kit_video/common/darwin/Classes/plugin/VideoOutput.swift` | `dependencies_and_vendored` | high | 0 | 216 | accept |
| D | `third_party/media_kit_video/common/darwin/Classes/plugin/VideoOutputConfiguration.swift` | `dependencies_and_vendored` | high | 0 | 33 | accept |
| D | `third_party/media_kit_video/common/darwin/Classes/plugin/VideoOutputManager.swift` | `dependencies_and_vendored` | high | 0 | 56 | accept |
| D | `third_party/media_kit_video/common/darwin/Classes/plugin/Worker.swift` | `dependencies_and_vendored` | high | 0 | 67 | accept |
| D | `third_party/media_kit_video/common/mpv/Package.swift` | `dependencies_and_vendored` | high | 0 | 7 | accept |
| D | `third_party/media_kit_video/common/mpv/README.md` | `dependencies_and_vendored` | high | 0 | 16 | accept |
| D | `third_party/media_kit_video/common/mpv/include/media_kit_mpv.h` | `dependencies_and_vendored` | high | 0 | 36 | accept |
| D | `third_party/media_kit_video/common/mpv/include/module.modulemap` | `dependencies_and_vendored` | high | 0 | 4 | accept |
| D | `third_party/media_kit_video/common/mpv/include/mpv/client.h` | `dependencies_and_vendored` | high | 0 | 2033 | accept |
| D | `third_party/media_kit_video/common/mpv/include/mpv/render.h` | `dependencies_and_vendored` | high | 0 | 766 | accept |
| D | `third_party/media_kit_video/common/mpv/include/mpv/render_dxgi.h` | `dependencies_and_vendored` | high | 0 | 18 | accept |
| D | `third_party/media_kit_video/common/mpv/include/mpv/render_gl.h` | `dependencies_and_vendored` | high | 0 | 211 | accept |
| D | `third_party/media_kit_video/common/mpv/media_kit_mpv.c` | `dependencies_and_vendored` | high | 0 | 88 | accept |
| D | `third_party/media_kit_video/ios/.gitignore` | `dependencies_and_vendored` | high | 0 | 3 | accept |
| D | `third_party/media_kit_video/ios/media_kit_video.podspec` | `dependencies_and_vendored` | high | 0 | 33 | accept |
| D | `third_party/media_kit_video/ios/media_kit_video/Package.swift` | `dependencies_and_vendored` | high | 0 | 24 | accept |
| D | `third_party/media_kit_video/ios/media_kit_video/Sources/media_kit_video/PrivacyInfo.xcprivacy` | `dependencies_and_vendored` | high | 0 | 14 | accept |
| D | `third_party/media_kit_video/ios/media_kit_video/Sources/media_kit_video/plugin/TextureHW.swift` | `dependencies_and_vendored` | high | 0 | 216 | accept |
| D | `third_party/media_kit_video/ios/media_kit_video/Sources/media_kit_video/plugin/common/MPVHelpers.swift` | `dependencies_and_vendored` | high | 0 | 37 | accept |
| D | `third_party/media_kit_video/ios/media_kit_video/Sources/media_kit_video/plugin/common/MPVVideoOutParams.swift` | `dependencies_and_vendored` | high | 0 | 59 | accept |
| D | `third_party/media_kit_video/ios/media_kit_video/Sources/media_kit_video/plugin/common/MediaKitVideoPlugin.swift` | `dependencies_and_vendored` | high | 0 | 176 | accept |
| D | `third_party/media_kit_video/ios/media_kit_video/Sources/media_kit_video/plugin/common/ResizableTextureProtocol.swift` | `dependencies_and_vendored` | high | 0 | 14 | accept |
| D | `third_party/media_kit_video/ios/media_kit_video/Sources/media_kit_video/plugin/common/SafeResizableTexture.swift` | `dependencies_and_vendored` | high | 0 | 54 | accept |
| D | `third_party/media_kit_video/ios/media_kit_video/Sources/media_kit_video/plugin/common/SwappableObjectManager.swift` | `dependencies_and_vendored` | high | 0 | 108 | accept |
| D | `third_party/media_kit_video/ios/media_kit_video/Sources/media_kit_video/plugin/common/TextureSW.swift` | `dependencies_and_vendored` | high | 0 | 161 | accept |
| D | `third_party/media_kit_video/ios/media_kit_video/Sources/media_kit_video/plugin/common/TextureSWContext.swift` | `dependencies_and_vendored` | high | 0 | 40 | accept |
| D | `third_party/media_kit_video/ios/media_kit_video/Sources/media_kit_video/plugin/common/UtilsProtocol.swift` | `dependencies_and_vendored` | high | 0 | 6 | accept |
| D | `third_party/media_kit_video/ios/media_kit_video/Sources/media_kit_video/plugin/common/VideoOutput.swift` | `dependencies_and_vendored` | high | 0 | 216 | accept |
| D | `third_party/media_kit_video/ios/media_kit_video/Sources/media_kit_video/plugin/common/VideoOutputConfiguration.swift` | `dependencies_and_vendored` | high | 0 | 33 | accept |
| D | `third_party/media_kit_video/ios/media_kit_video/Sources/media_kit_video/plugin/common/VideoOutputManager.swift` | `dependencies_and_vendored` | high | 0 | 56 | accept |
| D | `third_party/media_kit_video/ios/media_kit_video/Sources/media_kit_video/plugin/common/Worker.swift` | `dependencies_and_vendored` | high | 0 | 67 | accept |
| D | `third_party/media_kit_video/ios/media_kit_video/Sources/media_kit_video/plugin/gles/OpenGLESHelpers.swift` | `dependencies_and_vendored` | high | 0 | 181 | accept |
| D | `third_party/media_kit_video/ios/media_kit_video/Sources/media_kit_video/plugin/gles/TextureGLESContext.swift` | `dependencies_and_vendored` | high | 0 | 57 | accept |
| D | `third_party/media_kit_video/lib/media_kit_video.dart` | `dependencies_and_vendored` | high | 0 | 16 | accept |
| D | `third_party/media_kit_video/lib/media_kit_video_controls/media_kit_video_controls.dart` | `dependencies_and_vendored` | high | 0 | 14 | accept |
| D | `third_party/media_kit_video/lib/media_kit_video_controls/src/controls/adaptive.dart` | `dependencies_and_vendored` | high | 0 | 31 | accept |
| D | `third_party/media_kit_video/lib/media_kit_video_controls/src/controls/cupertino.dart` | `dependencies_and_vendored` | high | 0 | 99 | accept |
| D | `third_party/media_kit_video/lib/media_kit_video_controls/src/controls/extensions/duration.dart` | `dependencies_and_vendored` | high | 0 | 42 | accept |
| D | `third_party/media_kit_video/lib/media_kit_video_controls/src/controls/material.dart` | `dependencies_and_vendored` | high | 0 | 1937 | accept |
| D | `third_party/media_kit_video/lib/media_kit_video_controls/src/controls/material_desktop.dart` | `dependencies_and_vendored` | high | 0 | 1613 | accept |
| D | `third_party/media_kit_video/lib/media_kit_video_controls/src/controls/methods/fullscreen.dart` | `dependencies_and_vendored` | high | 0 | 117 | accept |
| D | `third_party/media_kit_video/lib/media_kit_video_controls/src/controls/methods/video_state.dart` | `dependencies_and_vendored` | high | 0 | 33 | accept |
| D | `third_party/media_kit_video/lib/media_kit_video_controls/src/controls/no.dart` | `dependencies_and_vendored` | high | 0 | 14 | accept |
| D | `third_party/media_kit_video/lib/media_kit_video_controls/src/controls/widgets/fullscreen_inherited_widget.dart` | `dependencies_and_vendored` | high | 0 | 72 | accept |
| D | `third_party/media_kit_video/lib/media_kit_video_controls/src/controls/widgets/video_controls_theme_data_injector.dart` | `dependencies_and_vendored` | high | 0 | 98 | accept |
| D | `third_party/media_kit_video/lib/media_kit_video_controls/src/controls/widgets/video_state_inherited_widget.dart` | `dependencies_and_vendored` | high | 0 | 110 | accept |
| D | `third_party/media_kit_video/lib/src/subtitle/subtitle_view.dart` | `dependencies_and_vendored` | high | 0 | 163 | accept |
| D | `third_party/media_kit_video/lib/src/utils/dispose_safe_notifer.dart` | `dependencies_and_vendored` | high | 0 | 12 | accept |
| D | `third_party/media_kit_video/lib/src/utils/query_decoders.dart` | `dependencies_and_vendored` | high | 0 | 68 | accept |
| D | `third_party/media_kit_video/lib/src/utils/wakelock.dart` | `dependencies_and_vendored` | high | 0 | 51 | accept |
| D | `third_party/media_kit_video/lib/src/video/video.dart` | `dependencies_and_vendored` | high | 0 | 7 | accept |
| D | `third_party/media_kit_video/lib/src/video/video_texture.dart` | `dependencies_and_vendored` | high | 0 | 531 | accept |
| D | `third_party/media_kit_video/lib/src/video/video_web.dart` | `dependencies_and_vendored` | high | 0 | 470 | accept |
| D | `third_party/media_kit_video/lib/src/video_controller/android_video_controller/android_video_controller.dart` | `dependencies_and_vendored` | high | 0 | 6 | accept |
| D | `third_party/media_kit_video/lib/src/video_controller/android_video_controller/real.dart` | `dependencies_and_vendored` | high | 0 | 339 | accept |
| D | `third_party/media_kit_video/lib/src/video_controller/android_video_controller/stub.dart` | `dependencies_and_vendored` | high | 0 | 29 | accept |
| D | `third_party/media_kit_video/lib/src/video_controller/native_video_controller/native_video_controller.dart` | `dependencies_and_vendored` | high | 0 | 6 | accept |
| D | `third_party/media_kit_video/lib/src/video_controller/native_video_controller/real.dart` | `dependencies_and_vendored` | high | 0 | 318 | accept |
| D | `third_party/media_kit_video/lib/src/video_controller/native_video_controller/stub.dart` | `dependencies_and_vendored` | high | 0 | 29 | accept |
| D | `third_party/media_kit_video/lib/src/video_controller/ohos_video_controller/ohos_video_controller.dart` | `dependencies_and_vendored` | high | 0 | 6 | accept |
| D | `third_party/media_kit_video/lib/src/video_controller/ohos_video_controller/real.dart` | `dependencies_and_vendored` | high | 0 | 231 | accept |
| D | `third_party/media_kit_video/lib/src/video_controller/ohos_video_controller/stub.dart` | `dependencies_and_vendored` | high | 0 | 29 | accept |
| D | `third_party/media_kit_video/lib/src/video_controller/platform_video_controller.dart` | `dependencies_and_vendored` | high | 0 | 187 | accept |
| D | `third_party/media_kit_video/lib/src/video_controller/video_controller.dart` | `dependencies_and_vendored` | high | 0 | 177 | accept |
| D | `third_party/media_kit_video/lib/src/video_controller/video_output_policy.dart` | `dependencies_and_vendored` | high | 0 | 42 | accept |
| D | `third_party/media_kit_video/lib/src/video_controller/video_params_geometry.dart` | `dependencies_and_vendored` | high | 0 | 44 | accept |
| D | `third_party/media_kit_video/lib/src/video_controller/web_video_controller/real.dart` | `dependencies_and_vendored` | high | 0 | 130 | accept |
| D | `third_party/media_kit_video/lib/src/video_controller/web_video_controller/stub.dart` | `dependencies_and_vendored` | high | 0 | 29 | accept |
| D | `third_party/media_kit_video/lib/src/video_controller/web_video_controller/web_video_controller.dart` | `dependencies_and_vendored` | high | 0 | 6 | accept |
| D | `third_party/media_kit_video/lib/src/video_view_parameters.dart` | `dependencies_and_vendored` | high | 0 | 98 | accept |
| D | `third_party/media_kit_video/linux/CMakeLists.txt` | `dependencies_and_vendored` | high | 0 | 21 | accept |
| D | `third_party/media_kit_video/linux/gl_render_thread.cc` | `dependencies_and_vendored` | high | 0 | 99 | accept |
| D | `third_party/media_kit_video/linux/include/media_kit_video/gl_render_thread.h` | `dependencies_and_vendored` | high | 0 | 42 | accept |
| D | `third_party/media_kit_video/linux/include/media_kit_video/media_kit_video_plugin.h` | `dependencies_and_vendored` | high | 0 | 34 | accept |
| D | `third_party/media_kit_video/linux/include/media_kit_video/texture_gl.h` | `dependencies_and_vendored` | high | 0 | 43 | accept |
| D | `third_party/media_kit_video/linux/include/media_kit_video/texture_sw.h` | `dependencies_and_vendored` | high | 0 | 42 | accept |
| D | `third_party/media_kit_video/linux/include/media_kit_video/utils.h` | `dependencies_and_vendored` | high | 0 | 13 | accept |
| D | `third_party/media_kit_video/linux/include/media_kit_video/video_output.h` | `dependencies_and_vendored` | high | 0 | 87 | accept |
| D | `third_party/media_kit_video/linux/include/media_kit_video/video_output_manager.h` | `dependencies_and_vendored` | high | 0 | 48 | accept |
| D | `third_party/media_kit_video/linux/media_kit_video_plugin.cc` | `dependencies_and_vendored` | high | 0 | 202 | accept |
| D | `third_party/media_kit_video/linux/texture_gl.cc` | `dependencies_and_vendored` | high | 0 | 479 | accept |
| D | `third_party/media_kit_video/linux/texture_sw.cc` | `dependencies_and_vendored` | high | 0 | 64 | accept |
| D | `third_party/media_kit_video/linux/utils.cc` | `dependencies_and_vendored` | high | 0 | 17 | accept |
| D | `third_party/media_kit_video/linux/video_output.cc` | `dependencies_and_vendored` | high | 0 | 530 | accept |
| D | `third_party/media_kit_video/linux/video_output_manager.cc` | `dependencies_and_vendored` | high | 0 | 75 | accept |
| D | `third_party/media_kit_video/macos/.gitignore` | `dependencies_and_vendored` | high | 0 | 3 | accept |
| D | `third_party/media_kit_video/macos/media_kit_video.podspec` | `dependencies_and_vendored` | high | 0 | 33 | accept |
| D | `third_party/media_kit_video/macos/media_kit_video/Package.swift` | `dependencies_and_vendored` | high | 0 | 24 | accept |
| D | `third_party/media_kit_video/macos/media_kit_video/Sources/media_kit_video/PrivacyInfo.xcprivacy` | `dependencies_and_vendored` | high | 0 | 14 | accept |
| D | `third_party/media_kit_video/macos/media_kit_video/Sources/media_kit_video/plugin/TextureHW.swift` | `dependencies_and_vendored` | high | 0 | 229 | accept |
| D | `third_party/media_kit_video/macos/media_kit_video/Sources/media_kit_video/plugin/Utils.swift` | `dependencies_and_vendored` | high | 0 | 37 | accept |
| D | `third_party/media_kit_video/macos/media_kit_video/Sources/media_kit_video/plugin/common/MPVHelpers.swift` | `dependencies_and_vendored` | high | 0 | 37 | accept |
| D | `third_party/media_kit_video/macos/media_kit_video/Sources/media_kit_video/plugin/common/MPVVideoOutParams.swift` | `dependencies_and_vendored` | high | 0 | 59 | accept |
| D | `third_party/media_kit_video/macos/media_kit_video/Sources/media_kit_video/plugin/common/MediaKitVideoPlugin.swift` | `dependencies_and_vendored` | high | 0 | 176 | accept |
| D | `third_party/media_kit_video/macos/media_kit_video/Sources/media_kit_video/plugin/common/ResizableTextureProtocol.swift` | `dependencies_and_vendored` | high | 0 | 14 | accept |
| D | `third_party/media_kit_video/macos/media_kit_video/Sources/media_kit_video/plugin/common/SafeResizableTexture.swift` | `dependencies_and_vendored` | high | 0 | 54 | accept |
| D | `third_party/media_kit_video/macos/media_kit_video/Sources/media_kit_video/plugin/common/SwappableObjectManager.swift` | `dependencies_and_vendored` | high | 0 | 108 | accept |
| D | `third_party/media_kit_video/macos/media_kit_video/Sources/media_kit_video/plugin/common/TextureSW.swift` | `dependencies_and_vendored` | high | 0 | 161 | accept |
| D | `third_party/media_kit_video/macos/media_kit_video/Sources/media_kit_video/plugin/common/TextureSWContext.swift` | `dependencies_and_vendored` | high | 0 | 40 | accept |
| D | `third_party/media_kit_video/macos/media_kit_video/Sources/media_kit_video/plugin/common/UtilsProtocol.swift` | `dependencies_and_vendored` | high | 0 | 6 | accept |
| D | `third_party/media_kit_video/macos/media_kit_video/Sources/media_kit_video/plugin/common/VideoOutput.swift` | `dependencies_and_vendored` | high | 0 | 216 | accept |
| D | `third_party/media_kit_video/macos/media_kit_video/Sources/media_kit_video/plugin/common/VideoOutputConfiguration.swift` | `dependencies_and_vendored` | high | 0 | 33 | accept |
| D | `third_party/media_kit_video/macos/media_kit_video/Sources/media_kit_video/plugin/common/VideoOutputManager.swift` | `dependencies_and_vendored` | high | 0 | 56 | accept |
| D | `third_party/media_kit_video/macos/media_kit_video/Sources/media_kit_video/plugin/common/Worker.swift` | `dependencies_and_vendored` | high | 0 | 67 | accept |
| D | `third_party/media_kit_video/macos/media_kit_video/Sources/media_kit_video/plugin/gl/OpenGLHelpers.swift` | `dependencies_and_vendored` | high | 0 | 264 | accept |
| D | `third_party/media_kit_video/macos/media_kit_video/Sources/media_kit_video/plugin/gl/TextureGLContext.swift` | `dependencies_and_vendored` | high | 0 | 45 | accept |
| D | `third_party/media_kit_video/ohos/.gitignore` | `dependencies_and_vendored` | high | 0 | 10 | accept |
| D | `third_party/media_kit_video/ohos/build-profile.json5` | `dependencies_and_vendored` | high | 0 | 10 | accept |
| D | `third_party/media_kit_video/ohos/hvigorfile.ts` | `dependencies_and_vendored` | high | 0 | 7 | accept |
| D | `third_party/media_kit_video/ohos/index.ets` | `dependencies_and_vendored` | high | 0 | 2 | accept |
| D | `third_party/media_kit_video/ohos/oh-package.json5` | `dependencies_and_vendored` | high | 0 | 9 | accept |
| D | `third_party/media_kit_video/ohos/src/main/ets/com/alexmercerind/media_kit_video/MediaKitVideoPlugin.ets` | `dependencies_and_vendored` | high | 0 | 105 | accept |
| D | `third_party/media_kit_video/ohos/src/main/ets/com/alexmercerind/media_kit_video/Utils.ets` | `dependencies_and_vendored` | high | 0 | 61 | accept |
| D | `third_party/media_kit_video/ohos/src/main/ets/com/alexmercerind/media_kit_video/VideoOutput.ets` | `dependencies_and_vendored` | high | 0 | 77 | accept |
| D | `third_party/media_kit_video/ohos/src/main/ets/com/alexmercerind/media_kit_video/VideoOutputManager.ets` | `dependencies_and_vendored` | high | 0 | 60 | accept |
| D | `third_party/media_kit_video/ohos/src/main/module.json5` | `dependencies_and_vendored` | high | 0 | 13 | accept |
| D | `third_party/media_kit_video/pubspec.yaml` | `dependencies_and_vendored` | high | 0 | 56 | accept |
| D | `third_party/media_kit_video/windows/.gitignore` | `dependencies_and_vendored` | high | 0 | 17 | accept |
| D | `third_party/media_kit_video/windows/CMakeLists.txt` | `dependencies_and_vendored` | high | 0 | 20 | accept |
| D | `third_party/media_kit_video/windows/d3d11_renderer.cc` | `dependencies_and_vendored` | high | 0 | 140 | accept |
| D | `third_party/media_kit_video/windows/d3d11_renderer.h` | `dependencies_and_vendored` | high | 0 | 94 | accept |
| D | `third_party/media_kit_video/windows/include/media_kit_video/media_kit_video_plugin_c_api.h` | `dependencies_and_vendored` | high | 0 | 30 | accept |
| D | `third_party/media_kit_video/windows/mailbox_swap_chain.cc` | `dependencies_and_vendored` | high | 0 | 279 | accept |
| D | `third_party/media_kit_video/windows/mailbox_swap_chain.h` | `dependencies_and_vendored` | high | 0 | 177 | accept |
| D | `third_party/media_kit_video/windows/media_kit_video_plugin.cc` | `dependencies_and_vendored` | high | 0 | 242 | accept |
| D | `third_party/media_kit_video/windows/media_kit_video_plugin.h` | `dependencies_and_vendored` | high | 0 | 57 | accept |
| D | `third_party/media_kit_video/windows/media_kit_video_plugin_c_api.cc` | `dependencies_and_vendored` | high | 0 | 20 | accept |
| D | `third_party/media_kit_video/windows/thread_pool.h` | `dependencies_and_vendored` | high | 0 | 91 | accept |
| D | `third_party/media_kit_video/windows/utils.cc` | `dependencies_and_vendored` | high | 0 | 107 | accept |
| D | `third_party/media_kit_video/windows/utils.h` | `dependencies_and_vendored` | high | 0 | 33 | accept |
| D | `third_party/media_kit_video/windows/video_output.cc` | `dependencies_and_vendored` | high | 0 | 495 | accept |
| D | `third_party/media_kit_video/windows/video_output.h` | `dependencies_and_vendored` | high | 0 | 142 | accept |
| D | `third_party/media_kit_video/windows/video_output_manager.cc` | `dependencies_and_vendored` | high | 0 | 55 | accept |
| D | `third_party/media_kit_video/windows/video_output_manager.h` | `dependencies_and_vendored` | high | 0 | 46 | accept |
| M | `tool/build_local_release.ps1` | `tooling_and_policy` | low | 16 | 0 | accept |
| A | `tool/check_listview_physics.py` | `tooling_and_policy` | low | 313 | 0 | accept |
| A | `tool/native/libmpv-android/README.md` | `tooling_and_policy` | low | 12 | 0 | accept |
| A | `tool/native/libmpv-android/build-abis.sh` | `tooling_and_policy` | low | 18 | 0 | accept |
| A | `tool/native/libmpv-android/build-arm64.sh` | `tooling_and_policy` | low | 16 | 0 | accept |
| A | `tool/native/libmpv-android/predidit-buildscripts.patch` | `tooling_and_policy` | low | 477 | 0 | accept |
| A | `tool/native/libmpv-linux/README.md` | `tooling_and_policy` | low | 19 | 0 | accept |
| A | `tool/native/libmpv-linux/build-x86_64.sh` | `tooling_and_policy` | low | 53 | 0 | accept |
| M | `tool/prefetch_android_native.ps1` | `tooling_and_policy` | low | 8 | 4 | accept |
| A | `tool/prefetch_linux_native.sh` | `tooling_and_policy` | low | 74 | 0 | accept |
| M | `tool/probes/acfun_navigation_probe_test.dart` | `tooling_and_policy` | low | 3 | 3 | accept |
| M | `tool/probes/acfun_public_contract_probe_test.dart` | `tooling_and_policy` | low | 2 | 2 | accept |
| M | `tool/probes/acfun_recording_probe_test.dart` | `tooling_and_policy` | low | 13 | 13 | accept |
| A | `tool/probes/all_sites_playback_probe_test.dart` | `tooling_and_policy` | low | 296 | 0 | accept |
| M | `tool/probes/bigo_metadata_probe_test.dart` | `tooling_and_policy` | low | 109 | 43 | accept |
| M | `tool/probes/bigo_snapshot_search_probe_test.dart` | `tooling_and_policy` | low | 3 | 3 | accept |
| A | `tool/probes/bigo_studio_probe_test.dart` | `tooling_and_policy` | low | 63 | 0 | accept |
| M | `tool/probes/cc_category_public_probe_test.dart` | `tooling_and_policy` | low | 3 | 3 | accept |
| M | `tool/probes/cmaf_rendition_window_probe_test.dart` | `tooling_and_policy` | low | 6 | 6 | accept |
| M | `tool/probes/danmaku_connection_matrix_probe_test.dart` | `tooling_and_policy` | low | 20 | 15 | accept |
| A | `tool/probes/douyu_splice_probe_test.dart` | `tooling_and_policy` | low | 125 | 0 | accept |
| M | `tool/probes/epg_backup_migration_probe_test.dart` | `tooling_and_policy` | low | 1 | 1 | accept |
| M | `tool/probes/hls_production_byterange_probe_test.dart` | `tooling_and_policy` | low | 1 | 1 | accept |
| M | `tool/probes/hls_retained_publication_probe_test.dart` | `tooling_and_policy` | low | 6 | 6 | accept |
| M | `tool/probes/hls_rolling_delivery_probe_test.dart` | `tooling_and_policy` | low | 12 | 12 | accept |
| D | `tool/probes/huajiao_application_probe_test.dart` | `tooling_and_policy` | low | 0 | 95 | accept |
| D | `tool/probes/huajiao_public_contract_probe_test.dart` | `tooling_and_policy` | low | 0 | 77 | accept |
| D | `tool/probes/huajiao_recommendation_search_probe_test.dart` | `tooling_and_policy` | low | 0 | 64 | accept |
| A | `tool/probes/huya_danmaku_ws_probe_test.dart` | `tooling_and_policy` | low | 107 | 0 | accept |
| M | `tool/probes/huya_message_board_probe_test.dart` | `tooling_and_policy` | low | 1 | 1 | accept |
| M | `tool/probes/huya_native_transport_probe_test.dart` | `tooling_and_policy` | low | 4 | 4 | accept |
| M | `tool/probes/huya_recorder_continuity_probe_test.dart` | `tooling_and_policy` | low | 21 | 21 | accept |
| M | `tool/probes/inke_public_contract_probe_test.dart` | `tooling_and_policy` | low | 6 | 6 | accept |
| M | `tool/probes/inke_showcase_search_probe_test.dart` | `tooling_and_policy` | low | 4 | 4 | accept |
| A | `tool/probes/itab_wallpaper_probe_test.dart` | `tooling_and_policy` | low | 116 | 0 | accept |
| M | `tool/probes/kilakila_application_probe_test.dart` | `tooling_and_policy` | low | 6 | 6 | accept |
| M | `tool/probes/kilakila_keyword_search_probe_test.dart` | `tooling_and_policy` | low | 4 | 4 | accept |
| M | `tool/probes/kilakila_link_probe_test.dart` | `tooling_and_policy` | low | 3 | 3 | accept |
| M | `tool/probes/kilakila_owner_probe_test.dart` | `tooling_and_policy` | low | 2 | 2 | accept |
| M | `tool/probes/kilakila_public_contract_probe_test.dart` | `tooling_and_policy` | low | 3 | 3 | accept |
| M | `tool/probes/kilakila_recording_probe_test.dart` | `tooling_and_policy` | low | 14 | 14 | accept |
| D | `tool/probes/langlive_room_probe_test.dart` | `tooling_and_policy` | low | 0 | 56 | accept |
| A | `tool/probes/looklive_media_headers_probe_test.dart` | `tooling_and_policy` | low | 182 | 0 | accept |
| M | `tool/probes/media_kit_buffering_probe_test.dart` | `tooling_and_policy` | low | 2 | 2 | accept |
| M | `tool/probes/missevan_keyword_search_probe_test.dart` | `tooling_and_policy` | low | 3 | 3 | accept |
| M | `tool/probes/missevan_public_contract_probe_test.dart` | `tooling_and_policy` | low | 6 | 6 | accept |
| M | `tool/probes/missevan_recording_probe_test.dart` | `tooling_and_policy` | low | 14 | 14 | accept |
| M | `tool/probes/niconico_directory_probe_test.dart` | `tooling_and_policy` | low | 2 | 2 | accept |
| M | `tool/probes/niconico_manager_probe_test.dart` | `tooling_and_policy` | low | 11 | 11 | accept |
| M | `tool/probes/niconico_metadata_probe_test.dart` | `tooling_and_policy` | low | 2 | 2 | accept |
| M | `tool/probes/niconico_playback_probe_test.dart` | `tooling_and_policy` | low | 6 | 6 | accept |
| M | `tool/probes/niconico_relay_probe_test.dart` | `tooling_and_policy` | low | 6 | 6 | accept |
| M | `tool/probes/niconico_session_probe_test.dart` | `tooling_and_policy` | low | 5 | 5 | accept |
| M | `tool/probes/niconico_site_probe_test.dart` | `tooling_and_policy` | low | 8 | 8 | accept |
| D | `tool/probes/openrec_application_probe_test.dart` | `tooling_and_policy` | low | 0 | 156 | accept |
| D | `tool/probes/openrec_public_contract_probe_test.dart` | `tooling_and_policy` | low | 0 | 76 | accept |
| M | `tool/probes/pandalive_native_search_probe_test.dart` | `tooling_and_policy` | low | 5 | 5 | accept |
| M | `tool/probes/picarto_public_contract_probe_test.dart` | `tooling_and_policy` | low | 5 | 5 | accept |
| M | `tool/probes/recorder_clock_matrix_probe_test.dart` | `tooling_and_policy` | low | 9 | 9 | accept |
| M | `tool/probes/recorder_controller_native_probe_test.dart` | `tooling_and_policy` | low | 18 | 18 | accept |
| M | `tool/probes/recorder_flv_access_unit_probe_test.dart` | `tooling_and_policy` | low | 9 | 9 | accept |
| M | `tool/probes/recorder_flv_stop_probe_test.dart` | `tooling_and_policy` | low | 7 | 7 | accept |
| M | `tool/probes/recorder_hls_partial_stop_probe_test.dart` | `tooling_and_policy` | low | 6 | 6 | accept |
| M | `tool/probes/recorder_hls_stop_probe_test.dart` | `tooling_and_policy` | low | 6 | 6 | accept |
| M | `tool/probes/recorder_http_connection_benchmark.dart` | `tooling_and_policy` | low | 1 | 1 | accept |
| M | `tool/probes/recorder_input_integrity_probe_test.dart` | `tooling_and_policy` | low | 9 | 9 | accept |
| M | `tool/probes/recorder_segment_clock_probe_test.dart` | `tooling_and_policy` | low | 10 | 10 | accept |
| M | `tool/probes/recorder_source_integrity_probe_test.dart` | `tooling_and_policy` | low | 5 | 5 | accept |
| M | `tool/probes/recording_clock_probe_support.dart` | `tooling_and_policy` | low | 2 | 2 | accept |
| M | `tool/probes/seventeenlive_public_catalog_probe_test.dart` | `tooling_and_policy` | low | 3 | 3 | accept |
| A | `tool/probes/tray_hot_restart_handle_probe_test.dart` | `tooling_and_policy` | low | 51 | 0 | accept |
| D | `tool/probes/tting_application_probe_test.dart` | `tooling_and_policy` | low | 0 | 268 | accept |
| D | `tool/probes/tting_hls_admission_summary.dart` | `tooling_and_policy` | low | 0 | 67 | accept |
| D | `tool/probes/tting_recording_probe_test.dart` | `tooling_and_policy` | low | 0 | 624 | accept |
| M | `tool/probes/twitcasting_hls_cookie_probe_test.dart` | `tooling_and_policy` | low | 3 | 3 | accept |
| M | `tool/probes/twitcasting_public_contract_probe_test.dart` | `tooling_and_policy` | low | 5 | 5 | accept |
| M | `tool/probes/weibo_metadata_probe_test.dart` | `tooling_and_policy` | low | 4 | 4 | accept |
| M | `tool/probes/weibo_recording_probe_test.dart` | `tooling_and_policy` | low | 14 | 14 | accept |
| M | `tool/probes/xiaohongshu_application_probe_test.dart` | `tooling_and_policy` | low | 7 | 7 | accept |
| M | `tool/probes/xiaohongshu_controller_native_probe_test.dart` | `tooling_and_policy` | low | 14 | 14 | accept |
| M | `tool/probes/xiaohongshu_share_link_probe_test.dart` | `tooling_and_policy` | low | 6 | 6 | accept |
| M | `tool/probes/xiaohongshu_share_probe_test.dart` | `tooling_and_policy` | low | 2 | 2 | accept |
| D | `tool/probes/zhanqi_metadata_probe_test.dart` | `tooling_and_policy` | low | 0 | 108 | accept |
| A | `tool/sync_owner_refs.ps1` | `tooling_and_policy` | low | 131 | 0 | accept |
| M | `tool/test-ghproxy.ps1` | `tooling_and_policy` | low | 1 | 1 | adapt |
| A | `tool/validate_architecture.py` | `tooling_and_policy` | low | 213 | 0 | accept |
| M | `tool/validate_build_policy.ps1` | `tooling_and_policy` | low | 10 | 1 | accept |
| M | `windows/packaging/msix/make_config.yaml` | `windows_native` | high | 1 | 1 | accept |
| M | `windows/runner/CMakeLists.txt` | `windows_native` | high | 40 | 40 | accept |
| M | `windows/runner/Runner.rc` | `windows_native` | high | 1 | 1 | accept |
| M | `windows/runner/flutter_window.cpp` | `windows_native` | high | 56 | 56 | accept |
| M | `windows/runner/flutter_window.h` | `windows_native` | high | 22 | 22 | accept |
| M | `windows/runner/main.cpp` | `windows_native` | high | 6 | 2 | accept |
