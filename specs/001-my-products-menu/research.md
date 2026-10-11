# Research: 我的产品栏目

**Feature**: [spec.md](./spec.md) | **Date**: 2026-10-11

所有结论都在 hugo55（v0.55.6）+ 仓库内 Academic 4.4.0 主题上用临时副本实际构建验证过（scratchpad，不影响仓库）。

## R1. 下拉菜单怎么做

- **Decision**：在 `config/_default/languages.toml` 的 `[[zh.menu.main]]` 里加一个父项「我的产品」（`identifier = "products"`，不设 `url`），两个子项用 `parent = "products"`。
- **Rationale**：
  - Academic 的 `navbar.html` 原生支持 `.HasChildren` 渲染 Bootstrap 下拉菜单（含手机端折叠菜单），不用改模板。
  - 实测：同名菜单项在 `languages.toml` 和 `menus.toml` 里写不同文字，页面显示的是 `languages.toml` 的 → **站点实际生效的是 `languages.toml` 里的 `zh.menu.main`**，`menus.toml` 被覆盖。
- **Alternatives considered**：改 `menus.toml`（无效，已实测）；覆盖 `navbar.html`（没必要）。
- **已核实**：现有「首页 / 博客 / 关于」在非首页上渲染为 `/#`、`/#posts`、`/#about`，从产品页点击能正常回首页，不需要改。

## R2. 产品页的页面结构

- **Decision**：每个产品一个 **widget page**：`content/product/<slug>/index.md`（`type: widget_page`，不 headless），同目录下每个 `.md` 是一个区块：
  - `hero.md`（`widget = "hero"`）：产品名、一句话定位、页内跳转按钮
  - `intro.md`（`widget = "featurette"`）：「产品介绍」，3–6 个能力卡片 → 对应幕布首页的「大标题 + 能力卡片」
  - `download.md`（自定义 `widget = "download"`）：「下载」，按平台分块 → 对应幕布下载页
  - `whatsnew.md`（自定义 `widget = "release_notes"`）：「新功能」，按发布倒序列摘要 → 对应幕布更新日志
- **Rationale**：Academic 4.4 的 `widget_page` 对非首页同样生效（`partials/widget_page.html` 用 `.File.Path` 取本页 bundle 的资源），实测 featurette 能正常渲染；首页已经在用这套机制，风格天然一致，明暗模式也由主题处理（FR-010）。区块的 `id` 由文件名决定（`#intro`、`#download`、`#whatsnew`），正好用作页内跳转（FR-003）。
- **Alternatives considered**：普通单页 + 手写 HTML（重复造轮子、明暗模式要自己处理）；把三部分拆成三个子页面（访客要多点击，不符合 SC-001）。

## R3. Releases 的内容结构与「新功能」的单一来源

- **Decision**：
  - 目录：`content/releases/_index.md`（总入口，可不进导航）→ `content/releases/<product>/_index.md`（产品 Releases 列表）→ `content/releases/<product>/<release-slug>/index.md`（单次发布详情）。
  - 每次发布的功能小节写在 **front matter 的 `items` 数组**里（`id`、`category`、`summary`、`detail`、可选 `image`），详情页按 `items` 渲染并给每节 `id` 锚点。
  - 产品页「新功能」区块（自定义 widget）读取同一批 release 页面的 `items[].summary`，链接到 `<release 页>#<item.id>`。
  - 自定义模板：`layouts/releases/list.html`、`layouts/releases/single.html`、`layouts/partials/widgets/release_notes.html`、`layouts/partials/widgets/download.html`。
- **Rationale**：
  - FR-014 要求摘要和详细说明同源；放在同一个 front matter 里，摘要和详情不可能不同步。
  - 锚点用显式 `id`，不依赖 Hugo 0.55（Blackfriday）对中文标题自动生成 id 的行为（不稳定）。
  - 实测：hugo55 正确生成 `/releases/pp-writer/` 列表与 `/releases/pp-writer/2026-w41/` 详情，`items[].detail | markdownify` 渲染正常。
  - Releases 不能放在 `content/product/<slug>/` 下面：产品页是 leaf bundle，子页面会被当成 widget 区块。
- **Alternatives considered**：`data/releases/*.yaml` 存数据（Hugo 0.55 不能从 data 生成页面，详情页做不出来）；正文里用 `## 标题` 分节（锚点不稳定，摘要要另外维护一份）。

## R4. 一次「发布」怎么划分

- **Decision**：按 **ISO 周** 合并：同一产品、同一周内完成的功能合成一次发布，slug 为 `<YYYY>-w<WW>`（如 `2026-w41`），标题由整理时根据本周主要功能起（如「笔记加锁与桌面待办」）。某周只有零碎修复的，并入「若干稳定性改进」一节。
- **Rationale**：pp-cloud 版本号基本不变（移动端 1.0.0、桌面版 0.1.0），没法按版本切；按 spec 的 git 首次提交时间统计，2026-06～10 共约 170 个相关 spec，按周合并约 20 次发布/产品量级，粒度接近 Notion Releases。
- **Alternatives considered**：按月（每次发布太长，失去「每次一个主题」的感觉）；一个 spec 一次发布（上百条，太碎）。

## R5. 新功能素材怎么从 pp-cloud 取

- **Decision**：
  - **范围**：`pp-cloud/docs/specs/` 中目录名带 `[pp-writer]`/`[pp-runner]`（含 `+web` 组合）的 spec；早期无标签的 002–028 号按内容判断，属于跑步 App 的归入 PP-Runner，纯 Web 后台的不收。
  - **只收已上线的**：spec 的 Status 是 Verified/真机通过/已合并的才收；纯脚本（如清理脚本、资源检查）、纯调试、CI、签名证书类不收。
  - **日期**：优先用对应 PR 合并的提交日期（`git log --merges`），没有则用 spec 的 `Created`。
  - **改写**：每个 spec 改写成「一句话摘要 + 2–4 句详细说明」，站在用户角度写「能做什么」，不写怎么实现。
  - **方式**：由 Claude 在实现阶段逐个读 spec 整理成 release 文件草稿，站长逐条审阅后才提交（Q3 = A：一次性整理，以后手动重跑）。
- **Rationale**：spec 里需求描述最接近「用户价值」，比 commit message 好改写；git 合并日期是真实上线时间。

## R6. 内部信息防泄露

- **Decision**：两道关：
  1. **人工审阅**：每个 release 文件提交前由站长逐条过目（SC-003）。
  2. **自动扫描脚本** `scripts/check-public-content.sh`：扫描 `content/product/` 与 `content/releases/`，命中禁止模式就以非 0 退出。禁止模式分两份：通用模式（IPv4、`localhost`、`内网`、`.sh`/`.py` 脚本名、`token`/`密钥`/`证书`/`keychain` 等）放在提交进仓库的 `scripts/public-content-denylist.txt`；具体敏感词（内部域名、主机名、公司代号、真实姓名）放在**不提交**的 `scripts/public-content-denylist.local.txt`，因为 GitHub 仓库是公开的，敏感词写进提交的文件本身就是泄露。脚本接入 Netlify 构建命令最前面（Netlify 上只有通用模式），命中就构建失败、不发布；具体敏感词只在本地提交前检查。
- **Rationale**：网站公开、pp-cloud 私有；人工容易漏，脚本兜底；接进 Netlify 保证即使本地忘了跑也发不出去。
- **Alternatives considered**：只靠人工（SC-003 要求 0 泄露，不够稳）；在 pp-cloud 侧做导出过滤（要动另一个仓库，Q3 已选不做自动同步）。

## R7. 下载区块

- **Decision**：自定义 `download` widget 读取区块 front matter 的 `platforms` 数组（`name`、`status`、`version`、`updated`、`note`）；当前所有平台 `status: beta`，显示「内测中，暂未开放下载」+ 联系方式链接（指向首页 `#about`）。以后开放下载时只需加 `url` 字段，模板显示下载按钮。
- **Rationale**：Q2 = A；数据和展示分开，以后开放下载不用改模板。

## R8. 验证方式（本仓库没有测试框架）

- **Decision**：
  - `hugo55` 构建 0 错误（**不加 `--gc`**，见 CLAUDE.md）。
  - `scripts/check-public-content.sh` 退出码 0；另放一个故意含 IP 的样例确认它会失败。
  - 对构建产物用 `grep` 做结构断言（菜单含两个子项、产品页含三个区块 id、每条「新功能」链接都能在对应 release 页找到锚点），写成 `scripts/check-products-build.sh`。
  - 浏览器人工检查：桌面 + 375px 宽度、明暗两种模式。
- **Rationale**：静态站点，构建产物就是全部行为；grep 断言足够且零依赖。
