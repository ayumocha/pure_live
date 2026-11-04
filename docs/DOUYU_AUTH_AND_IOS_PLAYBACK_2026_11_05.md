# 斗鱼认证简化 + iOS 播放问题：现状与方案

结论先行：**Windows 报毒已解决**；**斗鱼在 iOS 上的失败根因已用你自己的日志锁定**（斗鱼返回 `902 登录信息已过期`），
代码里已改成"遇到 902 自动降级游客重试"，但**还没在真机上验证**；`iOS 上虎牙也看不了` 这条已补 ATS 例外 + 全链路诊断，同样待验证。

---

## 一、这三件事的根因与状态

### 1. Windows 被杀软删除（已解决，你已复验）

| 项 | 内容 |
|---|---|
| 现象 | 卡巴斯基 `PDM:Trojan.Win32.Generic`，删除 `pure_live.exe`，换哈希重建后依旧 |
| 根因 | 打包脚本把 `msvcp140.dll`、`vcruntime140.dll`、`vcruntime140_1.dll` **放在 exe 同目录**。未签名 exe 从自身目录加载系统 DLL，是杀软判定的 DLL 侧载（DLL side-loading）形态 |
| 验证方式 | 只把这三个 DLL 从根目录移走 → 你复验「不再报毒」 |
| 修复 | 默认布局改为 `msvc-runtime/` 子目录（附 README 说明如何自救），`-WithAppLocalMsvc` 可恢复旧布局；`tool/validate_build_policy.ps1` 同步 |
| 提交 | `9aa25a7d6` |

> 附带说明：上游当初把这三个 DLL 放进根目录，是为了修 [#849](https://github.com/liuchuancong/pure_live/issues/849)（干净机器缺运行库启动不了），所以不能直接删；现在的做法是"包里有、但不在加载路径上"。

### 2. 斗鱼在 iOS 上"无法读取视频信息"（根因已定位，修复待真机验证）

你的诊断文件里这条是关键：

```
encryption-shape  body={error: 902, msg: 登录信息已过期，请重新登录}
```

- **不是** 网络问题、**不是** WAF 400（那是另一台机器/另一时刻的现象）；
- 斗鱼对"带了一个它已经不认的登录态"的请求，返回 902；
- 也就是说：**只要应用里存过斗鱼 cookie 又过期了，所有房间都会失败**——这正是上游 [#892](https://github.com/liuchuancong/pure_live/issues/892)（挂了两个月）的症状。

修复（`f426a83c2`）：识别 902 → 丢弃账号 cookie → **按游客重试**，成功/失败都恢复状态，不把用户卡在"登录已过期"。

### 3. iOS 上斗鱼、虎牙同时看不了（已加 ATS + 诊断，待验证）

- IPA 里 `Mpv.framework` 与全套 ffmpeg 都在，默认引擎是 mpv，引擎本身不缺；
- `Info.plist` 原本**没有任何 `NSAppTransportSecurity` 配置**，而这两家的拉流地址大量是 `http://`（`05e0509ec` 已加 `NSAllowsArbitraryLoads` 系列，并从构建出的 IPA 里核对过确实写入）；
- 同时补齐播放全链路诊断：`qualities-empty` / `qualities-failed` / `play-url-empty` / `sources-ready`（带 scheme、host）。

---

## 二、为什么斗鱼登录要手动找 cookie，能不能更简单

### 现状为什么麻烦

斗鱼的登录态只存在于**浏览器 cookie** 里。iOS 应用既拿不到 Safari 的 cookie（沙箱隔离），斗鱼也没有公开的第三方登录接口。所以现在只能：浏览器登录 → 复制整段 cookie → 粘贴进应用设置 → 7 天左右过期 → 再复制一遍。

过期后如果不清理，就会命中上面的 902，表现成"所有斗鱼房间都看不了"。

### 可选方案对比

| 方案 | 做法 | 用户操作 | 成本/风险 | 评价 |
|---|---|---|---|---|
| **A. 游客优先**（已实现一半） | 默认不带登录态播放；遇到 902 自动降级游客 | **零操作** | 部分房间/画质可能受限；送礼、弹幕身份不可用 | **建议作为默认**，先把"能看"做到极致 |
| **B. 应用内 WebView 登录**（推荐补充） | 应用内打开斗鱼 H5 登录页，登录完自动读取该 WebView 的 cookie 存起来 | 点一次"登录斗鱼"，输账号/扫码，**全程不碰 cookie 文本** | 依赖 `flutter_inappwebview`（**已在依赖里**）；斗鱼可能有滑块风控；cookie 仍只存本机 | **首选登录入口** |
| C. 扫码登录（官方接口） | 调斗鱼开放平台的二维码登录 | 最轻 | 无公开接口/需资质，逆向不稳定 | 暂不考虑 |
| D. 剪贴板一键导入 | 复制浏览器 cookie → 应用内"从剪贴板导入" | 一步点击 | 仍要用户操作、仍会过期 | 作为兜底保留 |
| E. 复用系统浏览器 cookie | — | — | iOS 沙箱不可能 | 不可行 |

**推荐组合：A（默认）+ B（可选登录）+ D（兜底）。** 这样"不想登录的人直接能看"，"要登录的人点一下就行"，都不需要再手动找 cookie。

### B 方案实施要点（确认后我来做）

1. 新增「斗鱼登录」页：`flutter_inappwebview` 打开 `https://m.douyu.com/`（或 passport 页），用户自己完成登录；
2. `onLoadStop` 后调 `CookieManager.getCookies(url:)`，筛出 `acf_auth` / `acf_jwt_token` / `LTP0` / `dy_did` 等字段；
3. 写入现有 `CookieSettingsController.douyuCookie` + `douyuCookieSavedAt`，复用已有 `ensureFreshSession` 续期逻辑（`LTP0` 能自动续，不用再手动更新）；
4. 登录成功后关闭 WebView，直播间自动重试一次；
5. 失败/超时只给提示，**不阻塞游客播放**；
6. 隐私：cookie 仅存本机；退出登录即清除；不做任何上传。

工作量估计：登录页 + cookie 抓取 + 与现有会话逻辑对接 + 3~5 个测试，约一轮实现 + 一轮真机验证。

---

## 三、待办清单

| # | 事项 | 状态 |
|---|---|---|
| 1 | Windows：运行库移出根目录 | ✅ 已提交，你已复验不再报毒 |
| 2 | 斗鱼 902 → 游客重试 | ✅ 已提交（`f426a83c2`），**待真机验证** |
| 3 | iOS ATS 例外 + 播放全链路诊断 | ✅ 已提交（`05e0509ec`），**待真机验证** |
| 4 | 虎牙是否随 ATS 修复 | ⏳ 待验证 |
| 5 | 斗鱼 WebView 登录（B 方案） | ⏳ 等你确认 |
| 6 | 斗鱼 3KB DLL 差异（bundle vs 包内）的来由 | ⏳ 待核实，与报毒无关 |

真机验证只需要一件事：装新包后点斗鱼/虎牙各一个直播间，把 `douyu_diagnose.txt` 发我。
若出现 `sources-ready` + 仍黑屏，说明"取到地址但播放器打不开"，那是另一条线（播放器/解码），看 `scheme=http` 还是 `https` 就能判断。

---

## 四、本轮文件整理记录（2026-11-05）

已删除（都是我在本轮调试时生成的一次性文件，未纳入 Git）：

- `local-artifacts/patch_*.py`（18 个，逐次改代码用的补丁脚本）
- `local-artifacts/douyu_*_test.dart`（12 个，临时探针：cookie 二分、did 矩阵、host 扫描、代理对比等）
- `local-artifacts/douyu-*.txt`（10 个，探针输出）
- `local-artifacts/duo-mockups/`、`duo-side-bar.png`（早期豆腐块渲染图）
- 中间产物目录：`ios-duo`、`ios-duo-2..5`、`ios-diag`、`ios-douyu-cookie`、`3.1.20-4201-no-msvc{,-diag}`

保留：

- `local-artifacts/ios-ats/`：最新 IPA（含 ATS + 902 修复之前的版本）
- `local-artifacts/3.1.20-4201/`：最新 Windows 便携包
- `local-artifacts/kaspersky-startup/`、`build-records/`、`repository-audits/`、`upstream-reviews/` 以及历史发布目录
- 仓库根目录：`git status` 干净，`master` 与 `origin/master` 同步于 `f426a83c2`
