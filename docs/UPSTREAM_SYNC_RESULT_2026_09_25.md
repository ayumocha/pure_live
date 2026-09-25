# 2026-09-25 独立分支同步结果

本次按用户选择，在 `codex/sync-upstream-20260925` 完整合入冻结上游 `9b376ec9ef25b532296871073a39075f6f9db397`，真实 merge 为 `a7c36b93`。`master` 保持 `e33795cc`，旧斗鱼补丁保存在 `codex/backup-douyu-recovery-20260925` 的 `b9f270b8`。候选版本 `3.0.8+4096`，Flutter `3.47.5`；候选未发布。

逐项审查见 [完整审计](UPSTREAM_AUDIT_9b376ec9ef25.md)：从共同祖先盘点 1,255 个上游提交、1,950 个文件；正式 merge 前对经审查的上游后继 `1362c204` 运行并通过强制合并门禁。审计中的历史上游报告不作为本次测试证据。

## 采用与适配

- 直接采用上游斗鱼取源、EOF/error 恢复和源提交机制，没有叠加旧本地恢复状态机。截图与“刷新后恢复”符合旧输入失效后继续 resume 的可能路径；缺少当时错误日志，不能据此确定每次停播的原因。
- 保留维护分支更新仓库、实际发布索引、布局约束和手动串行工作流。历史 `HANDOFF_3_0_7.md`、`STAGE_UPDATE_3_0_7.md` 保留为旧发布记录，以本报告解释候选状态。
- 将旧 `xhs` 收藏、历史、目录、房间设置映射到上游 `xiaohongshu`；保留旧主播主页和动态路径输入契约，并要求真实房间验证。
- 保留本地 `media_kit_video` 接口补丁和 `flv_lzc` 16 KB 原生修补；Git 依赖钉完整 SHA。Windows FFmpeg 使用 `wzgrx/pure_live` 的固定资产地址与固定 ZIP/DLL 哈希；新增缓存提取修复，避免 native hook 标记成功却没有 DLL。
- 上游未认证的局域网远程同步暂缓启用：入口、路由、监听及敏感处理保持关闭；本地备份、WebDAV 与原电视扫码保留。

## 回归发现与处置

以下为合并后实际测试发现的限定修复，覆盖原有语义，不以跳过失败代替修复。

| 范围 | 来源、首次无效状态与处置 |
| --- | --- |
| 首页侧栏 | `upstream-existing`：上游回退了可滚动 NavigationRail，短窗口 leading 溢出。恢复其先前滚动方案，保留主体布局；测试服务按生产方式 permanent 注册。 |
| Firebase 初始化 | `upstream-existing`：营销网站不可达就阻止 SDK 初始化。删除自动预检调用，保留 SDK 失败处理、关闭保护和重试入口；不改变认证或权限。 |
| 用户目录生命周期 | `upstream-existing`：上游去掉可替换的云端读写边界，旧测试因此接触未初始化 Firebase；同时权限查询完成前就提交游标，失败会跳过数据。恢复读写边界和整页提交，关闭后不再发布状态；动作测试隔离启动首刷，但保留真实搜索 Worker。 |
| 播放器输出设置 | `upstream-existing`：新页面列出不适用的平台驱动，旧测试仍查找对话框，窄屏警告行溢出。复用既有 MPV 平台驱动表，保持选择/返回语义，警告区域适配窄屏大字。 |
| 录制中心导航 | `upstream-existing`：弹窗 popped Future 早于退出动画完成。等待实际路由 completed 后导航；测试按实际路由动画时长验证。 |
| HTTP/FLV 测试 | `environment-or-data`：loopback 测试继承宿主 HTTP_PROXY，另一个流终止 fixture 同时在 onError/onDone 完成同一 Future。明确直连并一次消费终止事件；生产录制连接逻辑未改。 |
| 更新页 | `upstream-existing`：测试仍假定拼接附件 URL，而新实现读取显式附件表。测试提供实际附件表，并恢复控制器对缺失发布身份的防御检查，避免残留状态生成错误链接。 |
| 其他测试夹具 | 备份测试明确选择省略凭据；弹幕设置注册完整全局服务；TabBar 测试定位包装控件内的实际 TabBar；XHS 图标测试使用新资源并验证旧 ID 别名。 |
| 已删除的纹理组件 | 删除 `stable_video_layer_test.dart`：上游已删除生产组件，残留测试只测自身且忽略 visible 参数。保留真实 PlayerManager presentation、视频输出及 Windows PiP 回归，不恢复旧纹理策略。 |

## 验证记录

本机 Windows 上分批运行受影响测试，使用仓库资源互斥和 concurrency=12。当前 **423 个受影响测试文件通过**；另一个已脱离生产组件的旧测试文件已删除。首轮失败与修复后复测均保留，逐文件证据映射及日志 SHA-256 位于 `local-artifacts/upstream-reviews/affected-test-coverage.json`。为避开 Windows 命令长度限制，按 80 文件分批 Focused 执行；这不称为正式 Full 门禁。

最终静态分析执行一次：**0 errors、0 warnings、1 条 unnecessary_import info**（`web_search_controller.dart`）。记录 `local-artifacts/build-records/20260925T052230705Z-quality-focused.json`。最后一次备份复测 11 项通过（`20260925T052355535Z-quality-focused.json`）。实际源码修复已提交为 `d80c872c`，这些检查在该提交前的相同源码上完成，记录如实标注当时工作树为 dirty。

首次 Windows x64 Debug 构建及打包成功（未签名、未生成安装器；此包已由下方“镜像拦截修复”候选替代）：

- ZIP：`local-artifacts/3.0.8-4096-upstream-sync/PureLive-3.0.8-4096-windows-x64-debug.zip`，145,724,738 字节。
- ZIP SHA-256：`a8b1e80ca9cff1dbf9150a75eedfd2af41817ef12128f62e6678abcac6b97ae6`。
- 构建记录：`local-artifacts/build-records/20260925T053046315Z-build-windowsx64-debug.json`，源码 `d80c872c`，结束后 active heavy processes=0。构建元数据的 dirty=true 来自当时未提交的交接文档；运行代码没有追加未提交改动。
- 包内 `libffmpegkit.dll` SHA-256 为 `302d978048f389dbb07f01c1a34a4988a92d1e3ebf0e960e2dd8314f83632b34`；含 Flutter/MPV DLL 和候选版本清单，未含 `AppData`/`IPTV_CACHE` 运行数据。独立校验记录：`local-artifacts/upstream-reviews/windows-package-verification.json`。

首轮构建因 `windows/flutter/ephemeral` 缺少 C++ 包装源码和 Flutter DLL 报 C1083。SDK 原始文件完整、P: 映射正确、CMake 生成依赖存在；文件消失的具体原因未由日志确定。从同一固定 SDK 定点补回并核对六个关键文件哈希后，保留构建缓存串行重试成功。证据为 `windows-ephemeral-repair.json` 及失败/成功两轮构建日志。原生构建仍有第三方 CMake/MSVC/PDB 警告；没有把成功构建写成零警告。

测试和编译通过不代表已经完成真实长播或各平台原生验证。

已完成的独立证据包括：合并门禁、工作流语义/发布索引测试、扫描器回归、合并后全仓审计（0 errors、2 warnings：公开 TLS fixture 及空 catch 清单）、本地原生资产哈希与 Android AAR ELF 对齐核验。FFmpeg 提取 helper 的 7 项离线测试和真实固定 ZIP 提取通过。

## 镜像拦截修复（后续候选）

用户在上述 Windows 候选上收到卡巴斯基对 `v6.gh-proxy.org` 的网站拦截提示。修复基线为 `c2f7adea3644ed2fce77737a63563e37d0b91a5f`；该地址由上游 `163fc4159af0cedd5604b013d3c6f1e018f0ae41` 引入，属于 `upstream-existing`。启动时 `StartupController.loadHuyaUa → HuyaSite.getHuYaUA → GitHubMirror.mirrors → RaceHttp.fetchJson` 会并发请求候选源，因而即使正在观看斗鱼，也可能访问该域名。截图证明网站被拦截，不能据此认定可执行文件感染或杀毒软件误报；没有当时的进程网络日志。

另一个 `upstream-existing` 问题是 `ReleaseHistoryRepository._resolveSourceUrl` 在“官方更新源”开启时仍构造 `[raw, ...mirrors]`，设置尚未约束候选列表，竞速请求就已访问镜像。版本检查随后加载发布附件表，也会走该路径。

本次最小修复从公共 raw 镜像表及维护探测脚本移除被拦截域名，并使发布记录遵守官方源开关。版本检查和安装包下载的既有源选择继续保留；虎牙配置与字体下载使用公共镜像表，因此同样排除该域名。该开关仍只控制更新，其他镜像模式保持可用；不修改用户配置或杀毒软件设置。沿用未发布的 `3.0.8+4096`，仅更新独立分支 Windows 候选。

7 个受影响测试文件共 **34 项通过**，包含源列表排除、官方源失败时不请求镜像的本地 HTTP 回归、更新页面与下载流程。单次 Analyze 为 0 errors、0 warnings、1 条既有 unnecessary_import info；质量记录 `local-artifacts/build-records/20260925T064147381Z-quality-focused.json`，日志 `mirror-fix-focused.log`。策略门禁、PowerShell 语法和 `git diff --check` 通过；独立只读 Review 无阻塞。测试覆盖生产源选择函数及其 HTTP 竞速调用，未通过真实用户设置运行整个应用。旧 ZIP 的 `kernel_blob.bin` 仍可检出该域名（2 次），应改用完成核验后的新包。

修复源码提交 **`b0dfb22f58bc75b81a5666cf1675c9a1a292991d`**，从干净工作树构建 Windows x64 Debug 候选成功（未签名、未生成安装器）：

- 新 ZIP：`local-artifacts/3.0.8-4096-upstream-sync-mirror-fix/PureLive-3.0.8-4096-windows-x64-debug.zip`，145,719,339 字节。
- SHA-256：`a631ea4ee663b998ce4cd1757826c9740c3b8e4e793c80f7496cd5afd2bdac61`。
- 构建记录：`local-artifacts/build-records/20260925T064319610Z-build-windowsx64-debug.json`，结束后 active heavy processes=0。复用上述定向质量证据，没有重跑无关平台或完整回归。
- 包内 ZIP CRC、Windows 版本清单、Flutter/MPV/FFmpeg 运行库通过；FFmpeg DLL 哈希与固定版本一致。新 `kernel_blob.bin` 中被拦截域名出现次数为 **0**，包含修正后的源选择函数；包内不含用户运行数据。证据：`local-artifacts/upstream-reviews/windows-mirror-fix-package-verification.json`。
- 未启动应用或进行卡巴斯基运行时复测，不能宣称已覆盖所有网络请求或其他域名信誉。第三方原生构建仍有既有 CMake/MSBuild 警告；没有应用源码分析错误或警告。首次核验脚本误用 `mpv-2.dll` 文件名，按实际安装清单中的 `libmpv-2.dll` 更正后核验通过，产物未改动。

## 使用与回退边界

未启动用户正在使用的播放器，未安装应用、读取真实配置、操作手机/ADB 或发布 Release。真实 Windows 斗鱼长时间观看尚未采样；Android、Linux 和 Apple 原生构建未验证。新的 SQLite/Hive 数据不能声明可被旧版无损降级，试用应使用独立数据副本；源码回退点不等于数据降级工具。

FFmpeg helper 真实 ZIP 验证遗留临时目录 `C:\Users\ayu\AppData\Local\Temp\ffmpeg-real-archive-uhokd2xa`。递归清理由自动审批以 `blocked by policy` 拒绝，已停止清理，未绕过；不影响同步与构建。
