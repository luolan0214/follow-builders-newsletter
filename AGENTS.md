# AI Builders Digest / Newsletter — Agent 协作说明

> AI 使用中文交流。本文件是项目级长期记忆。

## 项目是什么

基于 Follow Builders 内容源的**双语 AI Builders 在线杂志**，静态站点部署到 GitHub Pages。

## 仓库信息

- 路径：`/Users/mac/code/Newsletter`
- 分支：`main`
- 部署：GitHub Pages（push 后自动发布）

## 目录结构

```
src/              # 核心 JS 逻辑（SOT）
scripts/          # 运行入口（从此处调用）
data/issues/      # 每日 JSON 数据（期数编号依据）
issues/           # 发布 HTML（*-rerun.html）
index.html        # 首页封面 + 往期目录
assets/avatars/   # 头像资源
launchd/          # 本机定时任务模板
```

## 发布流水线（手动）

指定日期 `YYYY-MM-DD`：

```bash
# 1. 生成 JSON
node scripts/build-daily-newsletter-json.js YYYY-MM-DD

# 2. 渲染 HTML（输出到 issues/，文件名带 -rerun）
node scripts/render-ai-builders-digest.js \
  data/issues/ai-builders-digest-YYYY-MM-DD.json \
  issues/ai-builders-digest-YYYY-MM-DD-rerun.html

# 3. 更新首页归档
node scripts/update-index-archive.js

# 4. 用户确认后再 commit / push
```

一键发布（含 agent 拉 feed）：

```bash
bash scripts/publish-daily-newsletter.sh
# 或指定日期、跳过步骤：
SKIP_AGENT=1 SKIP_PUSH=1 NEWSLETTER_DATE=2026-05-21 bash scripts/publish-daily-newsletter.sh
```

## 期数编号规则（重要）

- **编号来源（render 与 update-index 必须一致）**：
  - `data/issues/ai-builders-digest-*.json` 的日期
  - 已发布的 `issues/ai-builders-digest-*-rerun.html` 的日期（含无 JSON 的 legacy 期）
- 按日期 **chronological 排序**后从 `Issue 01` / `第 01 期` 递增
- 首页 `index.html` 的 `Issue NN` 必须与内页条带 `第 NN 期` 一致
- 正文顺序：**中文在上，英文在下**

**Legacy 第一期：** `2026-05-19` 仅有 HTML（`issues/ai-builders-digest-2026-05-19-rerun.html`），计为 Issue 01。不要当 stray 文件删掉。

**已知坑复盘：** 见 `docs/solutions/publishing-issues/issue-numbering-consistency.md`（2026-05-22 首页 Issue 03 vs 内页第 04 期不一致事件）。

## 自动发布（launchd）

- 本机 `launchd` 每天触发（需**电脑开机 + 已登录**；睡眠/关机则当天不跑）
- 实际运行仓库：`~/code/Newsletter-automation-live`（见 `~/Library/LaunchAgents/com.luolan.follow-builders-newsletter.plist`）
- 安装：`LAUNCHD_REPO_ROOT="$HOME/code/Newsletter-automation-live" bash scripts/install-launchd.sh`
- 日志：`~/Library/Logs/follow-builders-newsletter.log` / `.error.log`
- push 认证：定时任务走 `scripts/github-auth-helper.sh`，按仓库 owner（`luolan0214`）取 token，**不依赖当前激活的 gh 账号**

**已知坑复盘：** 2026-06-04/05 本地已生成但 push 失败导致断更，见 `docs/solutions/publishing-issues/issue-numbering-consistency.md` 事故二。

## 协作规则

### 续跑任务

用户说「继续跑 X 月 X 日」时：

1. `git status` 确认工作区
2. 检查 `data/issues/ai-builders-digest-YYYY-MM-DD.json` 是否已存在
3. 存在则先验证 JSON 完整性，再决定是否重跑 build
4. 渲染 → 更新 index → **等用户确认**再 commit / push

### 意外状态

发现与交接上下文不一致的未跟踪文件时：**先停下询问**，不要覆盖或继续流水线。

### Git

- **未经用户明确说「commit」「push」不要提交或推送**
- push 前确认 `index.html` 与 `issues/` 期数一致

## 交接包模板

```markdown
## 任务：Newsletter YYYY-MM-DD（第 N 窗）

### 已确认
- 仓库干净 / 或有 xxx 未提交变更
- JSON 是否存在
- 期数编号规则

### 下一步（只做一件）
- 例如：node scripts/build-daily-newsletter-json.js 2026-05-22

### 约束
- 不要自动 push
```

## 禁止

- 不要删除 `data/issues/` 里已有 JSON 除非用户明确要求
- 不要修改期数逻辑时重新引入 HTML 扫描
- 不要提交 API Key 或 `.env`
