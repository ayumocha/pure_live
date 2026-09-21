# 交接说明：v3.0.7（小红书直播接入 + 全平台发布）→ 后续维护者

> 面向接手本仓库的编码代理（Codex 等）。先读 [`AGENTS.md`](../AGENTS.md)、[`MAINTENANCE_POLICY.md`](../MAINTENANCE_POLICY.md)、[`BUILD_POLICY.md`](../BUILD_POLICY.md)、[`UPSTREAM_REVIEW_POLICY.md`](../UPSTREAM_REVIEW_POLICY.md)，本文档只补充**当前状态、本机环境前提与本轮沉淀的经验**。

## 1. 当前状态（2026-08-27）

| 项目 | 值 |
| --- | --- |
| 分支 / 提交 | `master` = `e426f928`（与 `origin/master` 同步，工作树干净） |
| 版本 | `3.0.7+4095`（`pubspec.yaml`、`assets/version.json`、`docs/STAGE_UPDATE_3_0_7.md` 一致） |
| 发布 | GitHub Release [`v3.0.7`](https://github.com/ayumocha/pure_live/releases/tag/v3.0.7)（Latest，8 个资产） |
| 发布仓库 | `ayumocha/pure_live`（本仓库 origin；上游为 `liuchuancong/pure_live`） |
| 测试 | 全量 **450/450 通过**（本机 Windows + GitHub Actions Ubuntu）；`flutter analyze` 零问题 |
| 版本线注意 | `RELEASE_NOTES.md` 中 v3.0.11~v3.0.14 条目是**未发布的超前文档**（仓库无对应 tag/release）；真实发布线为 3.0.6 → **3.0.7**。下次递增按 `pubspec.yaml` 基线走（3.0.8+4096） |

## 2. 本轮交付内容（25 个提交，`a218922b..e426f928`）

### 新平台：小红书直播（`xhs`，方案 A「链接观看」）

- `lib/core/site/xhs/xhs_site.dart`：免签名 SSR 解析（`window.__INITIAL_STATE__.liveStream`），支持
  - 链接形态：`livestream/{roomId}`、`livestream/{dynpath}/{roomId}`、`user/profile/{userId}`、`xhslink.com` 短链（跟随重定向）、分享文本内链接
  - 输出：直播状态（`success`/`fail`/`end`，标题含"回放"视为下播）、标题、封面、主播、人数（热度口径）、`pullConfig` 多档清晰度（h264/h265 `master_url`，AVC 优先）、`deeplink.flvUrl` 单档回退
  - **未开播/已结束不构造回退直链**（避免假直链）；`LiveSiteRoomRefresher` + `LiveSiteRecordRoomResolver` 严格模式
- 集成点：`lib/core/sites.dart`（注册）、`lib/common/models/live_room.dart`（热度口径）、`lib/common/utils/live_url_tool.dart`（工具箱解析 + 未开播一键关注）、`lib/modules/search/web_search_room_parser.dart` + `web_search_controller.dart`（🔗 粘贴入口）、`lib/main.dart`（Android 分享链接）、i18n（zh/en）、`assets/images/xhs.png`
- 平台边界（**不要当成缺陷重复调研**）：列表/分类浏览、原生搜索、实时弹幕**未接入**——`live-room.xiaohongshu.com` 系列接口要求浏览器级 `x-s` 签名（实测 Python 签名库 + 完整匿名 Cookie 直连返回 406），弹幕 WS 认证 `sid` 来自需签名的 `join/room`。协议细节见 `docs/STAGE_UPDATE_3_0_7.md`

### 顺带修复（均为既有欠账，测试即契约）

- 录制参数契约测试对齐原生参数向量（`ffmpeg_command_builder` 重构后的新契约），并修复 **user-agent 头大小写敏感** 的真实小缺陷
- 竖屏直播安全默认迁移（`PlayerSettingsController`：`enablePortraitStreamAdaptation`/`portraitAdaptiveHeight`/`portraitFullscreenPolicy`/`portraitPipFollowSource`/`portraitRoomOverrides`）
- 窗口 PiP 备份契约：`windowsPip` 保持 5 键结构，竖屏几何走独立顶层字段
- `build_local_release.ps1`：Windows 打包清单按配置目录解析（Debug 支持）
- `recording_platform_contract_test`：内置平台数 10 → 11
- 直播页布局不变量锚点注释补回（`live_play_content.dart` 的 `live-play-*-*` 三个 marker）
- CI 合规：workflow Action 全部钉 40 位 commit、Inno Setup/fastforge 固定版本、全平台 workflow 默认全 `false`、**平台阶段严格串行**

## 3. ⚠️ 仓库策略校验：改代码前必读

`tool/validate_build_policy.ps1` 会在完整质量门禁（`tool/local_ci.ps1 -Scope Full`）中**做结构性断言**，不了解会反复踩坑：

1. **布局不变量 marker**：`lib/modules/live_play/widgets/layout/live_play_content.dart` 必须保留 `live-play-portrait-stack`、`live-play-desktop-panel`、`live-play-video-only-layout` 三个字面量（注释锚点）
2. **播放器红线**：`lib/player/core/player_manager.dart` 不得出现 `return FittedBox(` 或 `StreamBuilder<List<int?>>`（当前**仍有一处**：`_buildVideoWidget` 为 Fijk/BetterPlayer 提供显式几何——属既有欠账，若要清理需把几何下沉到适配器并做 Android 真机验证）
3. **workflow marker**：`build_pure_live_release.yml` 需含 `needs: [quality, android]` / `needs: [quality, android, windows]` / `needs: [quality, android, windows, linux]` 与 `choco install innosetup --version=6.7.1`、`dart pub global activate fastforge 0.6.0`；`feature-build.yml` 有另一组 marker（含 `needs: [quality, windows]` 等）
4. **版本一致性**：`windows/packaging/msix/make_config.yaml` 的 `msix_version` 必须等于 `pubspec.yaml` 的 `版本.build`
5. **UI/设置/播放器改动**会连带触发上述检查；改前先跑 `PowerShell -ExecutionPolicy Bypass -File .\tool\validate_build_policy.ps1` 定位

## 4. GitHub Actions 语义坑（本轮踩过，务必记住）

- **`needs` 中的 job 被 skip 时，后继 job 默认也会被 skip**，即使 `if` 引用了 `needs.X.result`。必须写成
  `if: ${{ always() && <平台选择条件> && needs.<前置>.result != 'failure' }}`（保留失败即停的串行语义）
- 全平台 workflow 的 inputs 默认全 `false`（策略要求），触发时必须显式传：`build_windows/build_linux/build_macos/build_ios/build_android/run_quality/create_release/release_tag`
- 触发命令（已验证）：
  ```powershell
  gh api --method POST repos/ayumocha/pure_live/actions/workflows/build_pure_live_release.yml/dispatches `
    -f ref=master -F 'inputs[build_windows]=true' -F 'inputs[run_quality]=true' `
    -F 'inputs[create_release]=true' -F 'inputs[release_tag]=v3.0.8'
  ```
  （`gh workflow run -f ...` 也可，但 boolean/嵌套用 `gh api -F 'inputs[key]=...'` 最稳）
- Windows 阶段**签名可选**：有 `CERTIFICATE`/`CERTIFICATE_PASSWORD` secrets 时产出 EXE+MSIX+ZIP；**当前仓库无任何 Secrets**，因此产出 EXE+ZIP，Android 阶段未构建
- 接口探测（`tool/interface_probe.py`）在托管 runner 上受**出口地区限制**（`douyu.search` 等失败）；该步骤已 `continue-on-error`，权威探测在本机国内网络执行（40 项全 PASS）

## 5. 本机（Windows）开发环境事实

工具链均已安装（无需重装），路径如下——`tool/flutterw.ps1` 会自动发现 Flutter 与 JDK：

| 组件 | 路径 |
| --- | --- |
| Flutter 3.47.0 | `%LOCALAPPDATA%\Codex\flutter\sdk-3.47.0\flutter\bin\flutter.bat` |
| JDK 17（Temurin） | `%LOCALAPPDATA%\Codex\java\temurin-17\jdk-17.0.20.1+1`（够 AGP 9.3.1；README 写 Java 25 但未安装） |
| CMake 3.31.6 | `%LOCALAPPDATA%\Codex\cmake\cmake-3.31.6-windows-x86_64\bin`（已加入用户 PATH） |
| NuGet | `%LOCALAPPDATA%\Codex\nuget\nuget.exe`（`flutter_inappwebview_windows` 编译必需） |
| VS Build Tools 2026 | `C:\Program Files (x86)\Microsoft Visual Studio\18\BuildTools`（MSVC 14.50 + Win11 SDK 26100；**曾经注册损坏**，已通过提权 `setup.exe modify` 修复，vswhere 现可识别） |
| Android SDK | `%LOCALAPPDATA%\Android\Sdk`（`platforms;android-37.0`、`build-tools;37.0.0`、`ndk;28.2.13676358`、platform-tools；来自 canary channel，**Android 构建尚未跑通验证**） |
| 原生依赖缓存 | `%LOCALAPPDATA%\PureLive\native-cache`（media-kit jar ×4、ffmpeg-android aar、ffmpeg-windows zip、firebase-cpp-sdk） |
| 代理 | `127.0.0.1:7890`（构建/下载外部依赖时设 `HTTPS_PROXY`/`HTTP_PROXY`；`curl.exe` 需显式 `-x`） |

三个非显然的坑（已绕过，勿重踩）：

1. **Windows 未开启开发者模式** → Flutter 创建插件 symlink 失败。解决办法：用 **junction** 预建 `.plugin_symlinks`
   ```powershell
   $d = Get-Content .flutter-plugins-dependencies -Raw | ConvertFrom-Json
   foreach ($p in $d.plugins.windows) { New-Item -ItemType Junction -Path "windows\flutter\ephemeral\.plugin_symlinks\$($p.name)" -Target ($p.path -replace '\\\\','\') }
   ```
   （`linux` 平台同理；否则 `flutter test/build` 直接失败）
2. **FFmpegKit 的 native-assets hook 在 Windows 解压失效**（PowerShell 引号解析问题），需要预构建缓存：
   `.dart_tool\hooks_runner\shared\ffmpeg_kit_extended_flutter\build\ffmpeg_kit_cache\windows\bundle-base-windows-x86_64-shared-lgpl\bundle-base-windows-x86_64-shared-lgpl\`（双层）+ 外层 `.extract_complete`
   **注意**：任何 Android 构建前的 `prefetch_android_native.ps1` 可能 `Reset-FFmpegWindowsExtractionIfNeeded` 清掉它 → 重新解压即可（zip 在 native-cache）
3. **Gradle distribution 曾被中断损坏**（`zip END header not found`）→ 删除 `%USERPROFILE%\.gradle\wrapper\dists\gradle-9.5.0-*` 后重试

## 6. 常用命令

```powershell
# 依赖（首次或 pubspec 变更后）
$env:HTTPS_PROXY='http://127.0.0.1:7890'; .\tool\flutterw.ps1 pub get

# 定向验证 / 完整质量门禁（后者含全量测试 + 一条 analyze + 仓库审计）
.\tool\flutterw.ps1 test --no-pub --concurrency=12 test/xhs_site_test.dart
PowerShell -ExecutionPolicy Bypass -File .\tool\local_ci.ps1 -Scope Focused -TestPath test/xhs_site_test.dart -Analyze
PowerShell -ExecutionPolicy Bypass -File .\tool\local_ci.ps1 -Scope Full     # 会先跑 validate_build_policy（见第 3 节）

# 单平台本机构建（一次只构建一个目标；-SkipQuality 仅在证据已存在时用）
.\tool\build_local_release.ps1 -Target WindowsX64 -Configuration Release -SkipQuality
.\tool\build_local_release.ps1 -Target AndroidArm64 -Configuration Release -SkipQuality

# 全平台发布（推荐路径，见第 4 节）
gh api --method POST repos/ayumocha/pure_live/actions/workflows/build_pure_live_release.yml/dispatches ...
gh run watch <run-id> -R ayumocha/pure_live --exit-status
```

产物与证据：构建包在 `local-artifacts/<version>/`；每次重型任务的 JSON 记录在 `local-artifacts/build-records/`（含命令、提交、耗时、缓存命中、资源峰值）。

## 7. 待办 / 未覆盖（接手后按需推进）

1. **Android 正式包**：仓库无签名 Secrets。需要用户提供 keystore 后配置 4 个 secrets（`KEYSTORE_BASE64`/`STORE_PASSWORD`/`KEY_PASSWORD`/`KEY_ALIAS`），再触发 `build_android=true`；本机 Android 构建链路（SDK/NDK 已装）**尚未端到端验证**
2. **`player_manager.dart` 的 FittedBox 几何层**：策略红线欠账，清理需下沉到 Fijk/BetterPlayer 适配器 + Android 真机验证
3. **小红书能力扩展**（可选）：若未来出现免签名接口或可接受的登录 Cookie 通道，可评估列表/搜索/弹幕；当前结论见 `docs/STAGE_UPDATE_3_0_7.md`
4. **`RELEASE_NOTES.md` 版本线**：v3.0.11~v3.0.14 超前文档与真实发布线不一致，建议在下次发布时统一说明或归档
5. **Actions 探测步骤**：如仓库迁到国内 runner 或自建 runner，可恢复为强校验

## 8. 验证证据索引

- 发布：`gh release view v3.0.7 -R ayumocha/pure_live`（8 资产：Windows ZIP+EXE、Linux tar.gz、macOS zip+dmg、iOS ipa+app zip、BUILD_METADATA.json）
- 关键 CI 运行：全平台 `33107618074`（quality+Linux+Apple+Release 全绿）、Windows 专项 `33112626858`（Windows job success）
- 本机构建记录：`local-artifacts/build-records/`（Windows Release `20260827T135207050Z`、Debug 若干）
- 测试：450/450（含 `test/xhs_site_test.dart` 24 项小红书契约）
