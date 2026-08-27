# v3.0.7 阶段更新：小红书直播接入（链接观看）+ Windows 正式版

## 背景

本阶段为仓库新增**小红书直播平台**支持，并按方案 A（链接观看）接入：小红书未提供免签名的房间列表/搜索/实时弹幕接口（`live-room.xiaohongshu.com` 系列 API 需要浏览器级 `x-s`/`x-t`/`x-s-common` 签名与浏览器环境，实测 Python 签名库 + 完整匿名 Cookie 直连返回 406），因此平台能力边界为：

- ✅ 直播间/主播主页链接解析与播放（免签名 SSR 通道）
- ✅ 多档清晰度（`pullConfig` h264/h265 `master_url`）、直播状态、封面/主播/人数
- ✅ 收藏关注（未开播/已结束也可加入）、历史、刷新、录制接口契约
- ⛔ 平台内列表/分类浏览、原生搜索、实时弹幕（无免签名通道；弹幕 WS 认证依赖签名接口）

## 协议调研结论（2026-08 抓包 + 三方交叉验证）

- 列表接口：`live-room.xiaohongshu.com/api/sns/red/live/web/feed/v1/squarefeed`（`source=13&category=0&cursor_score=…`），要求 `x-s` 签名头（随机匿名 a1 + xhshow 算法生成的 XYS_ 签名仍然 406，判定为浏览器环境指纹校验）。
- 免签名 SSR：`www.xiaohongshu.com/livestream/{roomId}` 与 `user/profile/{userId}`，移动端 UA（`ios/7.830 …`）请求后解析 `window.__INITIAL_STATE__`：
  - 在播：`liveStream.liveStatus="success"`，`roomInfo` 含 `roomId/roomTitle/roomCover/pullConfig{h264[],h265[]}/deeplink`，`displayCountInfo.displayCount` 按热度口径展示。
  - 已结束/未开播：`liveStatus="end"/"fail"`，保留标题/封面/主播信息，`roomId/pullConfig/deeplink` 缺失——按明确下播处理且**不构造回退直链**。
  - 标题含"回放"视为下播（与 streamget/rust-srec/biliLive-tools 三方契约一致）。
- 链接形态（实测）：`livestream/{房间号}`、`livestream/{动态段}/{房间号}`（dynpath 平台动态前缀）、`user/profile/{主播ID}`、`xhslink.com` 短链（HTTP 重定向）。
- 弹幕 WS（`wss://apppush-rws.xiaohongshu.com/rwp`，auth→register→subscribe→心跳→`t:4` base64 数据帧）协议已逆向，但 `sid` 认证来自需签名的 `join/room` 接口，免签不可达。

## 实现摘要

| 模块 | 变更 |
| --- | --- |
| `lib/core/site/xhs/xhs_site.dart` | 新增：SSR 解析、`pullConfig` 档位、deeplink 回退、`LiveSiteRoomRefresher`/`LiveSiteRecordRoomResolver` 严格模式、未开播无假直链 |
| `lib/core/sites.dart` | 注册 `xhs` 平台（常量/支持列表/`Sites.of`） |
| `lib/common/models/live_room.dart` | xhs 人数口径注册为热度，能力表 `hasPopularity` |
| `lib/common/utils/live_url_tool.dart` | 工具箱解析：xiaohongshu 直链/主页/短链/dynpath/文本提取；未开播一键关注（三条工具路径） |
| `lib/modules/search/web_search_room_parser.dart` | 网页链接识别：livestream 单段/双段、user/profile |
| `lib/modules/search/web_search_controller.dart` | 🔗 粘贴链接入口（复用 `LiveUrlTool`，获得短链/文本提取能力） |
| `lib/modules/toolbox/toolbox_controller.dart` | 剪贴板自动识别加入 xiaohongshu/xhslink |
| `lib/main.dart` | Android 分享通道：分享文本中的直播间链接直接进入房间 |
| `tool/build_local_release.ps1` | 修复 Windows 打包清单根路径（Debug 配置支持，Release 不变） |
| i18n/资产 | `site_xiaohongshu`、链接入口提示、`toolbox_live_offline*`、支持列表帮助文本；`assets/images/xhs.png` 风格化图标 |

## 验证证据

- 确定性回归：`test/xhs_site_test.dart` 24 项（SSR live/fail/end/回放/undefined 修复、pullConfig 多档与排序、deeplink 单档、未开播无假直链、严格刷新抛错、dynpath/短链/文本链接、收藏有效性、既有平台不回归）；`flutter analyze` 零问题。
- Windows x64 Debug 实机验证（用户侧）：真实直播间跳转、未开播/已结束解析与关注、dynpath 双段链接。
- 正式构建：Windows x64 Release（便携 ZIP + EXE 安装器），SHA256/构建元数据随附。

## 平台范围

- 本轮正式交付 **Windows x64**（用户实机验证平台）。
- Android/Linux/macOS/iOS 源码保留，本轮未重新构建；Android 后续版本闭环另行安排。

## 剩余已知限制

- 无小红书平台内列表/分类浏览、原生搜索、实时弹幕（免签名通道不存在）。
- SSR 页面结构随平台改版可能漂移（解析器对结构错误采用严格抛出/普通下播的分级容错）。
- `displayCountInfo` 未区分在线还是累计，按热度口径展示（可在"观看数据与排行口径"设置中管理）。
