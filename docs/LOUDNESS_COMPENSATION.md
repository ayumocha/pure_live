# 手动响度补偿

## 范围与使用

用户明确要求为偏小的直播声音增加补偿。开发分支 `codex/loudness-compensation` 基于
`54689e2eef02f8267ee9c11a79ef7f46f6155007`；发布版本仍为 `3.0.8+4096`，本功能不在现有 GitHub Release 内。

播放设置 → 音频设置 → 手动响度补偿：关闭 / 轻柔 +3 dB / 标准 +6 dB / 强力 +9 dB。
全局设置覆盖 MPV 主播放器及多画面，每个播放器保持自己的普通音量与静音状态。
默认关闭，建议先选轻柔。此功能是手动增益，不是自动 LUFS 均衡或峰值限制；
较响音源在高档位可能削波失真。IJK 不提供此选项。

## 诊断与取舍

- 冻结上游：`9b376ec9ef25b532296871073a39075f6f9db397`。此前“Windows 抖音比浏览器小声”的
  来源分类仍为 `not-reproduced`；本改动是用户指定的功能，不能当作该差异根因已修复。
- 已读调用链：UI 0..1 → PlayerManager 0..1 → MediaKitAdapter ×100 → MPV 0..100，
  没有发现抖音专属衰减。所给公开房间不同画质/编码样本的重叠 AAC 帧逐字节相同。
  抖音网页代码具备基于响度元数据的处理能力，但配置证据不足以证明该次网页实际启用。
- 现有 Windows MPV 的 FFmpeg 构建仅显式启用 `overlay` / `equalizer`。
  离线开流证明 `dynaudnorm` 不可用；仅 `af add` 返回成功不能证明滤镜可执行。
  因此不向播放实例添加该滤镜。
- Windows 视频插件依赖 Predidit 的 DXGI 扩展，通用完整版 MPV 无法直接替换并保留现有渲染行为。
  使用已验证的内置 `volume-gain` 属性可避免变更二进制、视频渲染、转码或缓冲路径。
  对该属性的定义参见 [MPV 手册](https://mpv.io/manual/stable/#options-volume-gain)；
  滤镜构建范围参见 [锁定原生构建配置](https://github.com/Predidit/libmpv-win32-video-cmake/blob/fdf7512/packages/ffmpeg.cmake)。

## 生命周期与配置

- `MpvLoudnessBinding` 随每个原生播放器创建，开流前应用保存值；监听后续设置事件，串行处理写入，
  以最新请求为准。关闭只写 0 dB，不改普通音量、静音、其他滤镜或媒体地址。
- 锁定的 media_kit `setProperty` 忽略原生返回码，故写入后回读并验证有限数值。
  失败记录日志并提示，不转成播放错误或重连。无法确认结果时保留“不确定”状态，切回关闭仍强制写入 0 dB。
  重选同档可重试。界面展示保存的请求档位；实际应用失败时以即时提示为准。
- 销毁先取消设置订阅、等待在途写入，再销毁原生播放器；初始化期间退出不再创建绑定。
  主播放器的画面/纯音频模式、软停与换流保留同一绑定；多画面各自持有绑定。
- 新键 `loudnessCompensationMode` 纳入保存、导入导出和重置。旧配置、未知值或错误类型默认关闭。
  关闭即可恢复原始增益；降级到旧版时额外配置键不会启用增益，无数据库迁移。

## 验证

改动前及收尾 `tool/validate_build_policy.ps1` 均通过。10 个受影响测试文件初次执行通过 157 项，
两项新测试因 GetX 异步通知的等待方式失败；修正测试事件等待后，相关两个文件 13 项全部通过。
生产代码未因测试时序失败而增加延时。其余 8 个文件的通过结果复用。静态检查退出码为 0，
无 error/warning，6 条 info（含既有 `web_search_controller.dart` 冗余导入和本功能的风格提示）。
记录：`20260925T091030959Z-quality-focused.json`（首轮）、
`20260925T091334898Z-quality-focused.json`（复测及 Analyze），均在 `local-artifacts/build-records/`。
独立只读代码评审未发现阻塞问题。

`tool/probes/libmpv_loudness_probe.py` 使用实际 Windows DLL 向本地 PCM WAV 输出，
不打开声音设备、用户配置或网络地址。验证静音、0 音量、关档恢复、档位不累加、声道比例、
持续时间及不改其他音频滤镜。记录：`local-artifacts/loudness-compensation/native-probe/result.json`。

- DLL SHA-256：`361e3a306707454a24e7d3558b2eb7a9ccc23a4f5ed396fe7e77f0a44908eda5`。
- 小声信号实测增益：+3.0085 / +6.0040 / +9.0059 dB；其余上述断言通过。
- 接近满幅信号出现削波，符合手动增益限制，UI 已明确提示；未宣称自动限幅。
- 未对用户实际声卡/扬声器试听，也未验证 Android/macOS/iOS/Linux 的原生增益。
  本轮不改已发布资产或其他平台更新源。

## Windows 候选包

- 源码提交：`0b4f7032295dcc18eb17d975b8b0184d50bb2444`，干净工作树构建。
- 命令：`tool/build_local_release.ps1 -Target WindowsX64 -Configuration Release -SkipQuality -SkipInstaller -CandidateLabel loudness`。
  使用上述定向测试证据，候选包不冒充完整正式发布门禁。
- 产物：`local-artifacts/3.0.8-4096-loudness/PureLive-3.0.8-4096-windows-x64-portable.zip`，76,648,377 字节。
- ZIP SHA-256：`23014677fa083270009f5cb0357691f8bada7acba612bb75ff477945dfe9deed`。
- ZIP CRC、内置响度补偿翻译及用户数据排除检查通过；包内唯一 MPV DLL 的哈希与上述音频验证相同。
- 构建成功，耗时 88.575 秒，结束后活跃重型进程为 0；记录
  `local-artifacts/build-records/20260925T091549363Z-build-windowsx64-release.json`。
  原有 CMake CMP0175 / MSBuild MSB8028 构建警告仍存在，未阻塞本次打包。
- 未启动或安装候选客户端，未合并到 master，也未上传或替换 GitHub Release。
