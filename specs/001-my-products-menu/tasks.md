---

description: "我的产品栏目 —— 任务清单"
---

# Tasks: 我的产品栏目（小纸条 PP-Writer / 跑步 PP-Runner）

**Input**: Design documents from `/specs/001-my-products-menu/`

**Prerequisites**: plan.md、spec.md、research.md、data-model.md、contracts/、quickstart.md

**Tests**: 本仓库没有测试框架。验证方式是 [contracts/check-scripts.md](./contracts/check-scripts.md) 中的两个脚本：每个用户故事先把它的断言加进 `scripts/check-products-build.sh`（先失败），再实现到通过。

**Organization**: 按用户故事分组。注意 **US3「新功能」依赖 US4 的 Releases 页面和数据**（摘要要链接到详情页锚点），所以执行顺序是 US1 → US2 → US4 → US3，与优先级编号不同。

## 全局约定（每个任务都适用）

- 构建只用 `hugo55`，**不加 `--gc`**；构建输出放临时目录：`OUT=$(mktemp -d); hugo55 -d "$OUT"`（审阅草稿时加 `-D`）
- 不修改 `themes/academic/` 下任何文件；只在根目录 `layouts/`、`content/`、`config/`、`assets/`、`scripts/` 新增或修改
- 模板只能用 Hugo 0.55.6 支持的函数
- 仓库是公开的：提交的文件不得出现内部域名、IP、公司代号、真实姓名、脚本名等内部信息
- front matter 格式以 [contracts/content-schema.md](./contracts/content-schema.md) 为准，网址和菜单以 [contracts/urls-and-menu.md](./contracts/urls-and-menu.md) 为准

## Format: `[ID] [P?] [Story] Description`

- **[P]**: 可并行（不同文件、不依赖未完成的任务）
- **[Story]**: 所属用户故事（US1–US4）

---

## Phase 1: Setup

**Purpose**: 建好脚本目录和断言脚本骨架

- [X] T001 新建 `scripts/check-products-build.sh`：接收构建输出目录参数（缺参数退出码 2），提供 `pass`/`fail` 两个辅助函数，逐条输出 `PASS`/`FAIL + 说明`，结尾汇总，有失败则退出码 1；先只实现断言 #9（首页仍含 `id="posts"`、`id="about"` 区块，导航中「首页 / 博客 / 关于」三项链接为 `href="/#"`、`href="/#posts"`、`href="/#about"`（首页和其他页面都是这样，已用当前 `master` 构建结果核实））和断言 #10（全站 HTML 不含 `mubu.com`）；对当前站点执行，确认两条都 PASS
- [X] T002 [P] 新建 `scripts/public-content-denylist.txt`：只放通用模式（每行一个 `grep -E` 正则，`#` 为注释）：IPv4 地址、`localhost`、`内网`、`内部`、`\.sh\b`、`\.py\b`、`[Tt]oken`、`密钥`、`证书`、`[Kk]eychain`、`[Pp]assword`、邮箱格式；文件里不得出现任何具体的域名、主机名、公司名、人名
- [X] T003 [P] 在 `.gitignore` 末尾追加 `scripts/public-content-denylist.local.txt`

---

## Phase 2: Foundational（阻塞后续内容提交）

**Purpose**: 内部信息扫描脚本，必须在任何「新功能」/Releases 内容提交前就位

- [X] T004 新建 `scripts/check-public-content.sh`，按 [contracts/check-scripts.md](./contracts/check-scripts.md) 实现：默认扫描 `content/product`、`content/releases`（目录不存在时跳过并提示），也可传入目录参数；读取 `scripts/public-content-denylist.txt`（缺失则退出码 2）以及存在时的 `scripts/public-content-denylist.local.txt`（不存在时输出「未加载本地敏感词表」）；忽略空行和 `#` 注释；输出 `<文件>:<行号>: <模式>`；命中退出码 1，否则 0；草稿也扫描；只用 bash + grep + find，macOS 和 Linux 都能跑
- [X] T005 验证 T004：在临时目录放一个含 `10.1.2.3` 的 `index.md`，执行脚本应退出码 1 并指出该行；对仓库默认目录执行应退出码 0（quickstart 第 1 步）
- [X] T006 修改 `netlify.toml`：`[build]`、`[context.deploy-preview]`、`[context.branch-deploy]` 三条构建命令最前面加 `bash scripts/check-public-content.sh && `（加在下载 Hugo 之前）；用 Python `toml` 库解析确认三条命令拼接正确
- [X] T007 本地准备 `scripts/public-content-denylist.local.txt`（**不提交**）：从 pp-cloud 的配置和文档中收集内部域名、主机名、内网 IP 段、公司/项目代号、真实姓名，每行一个正则；执行 `git status` 确认该文件不出现在未跟踪列表中

**Checkpoint**: 扫描脚本可用，Netlify 构建有防泄露关卡

---

## Phase 3: User Story 1 - 从导航进入产品页了解产品 (Priority: P1) 🎯 MVP

**Goal**: 导航有「我的产品」下拉菜单，两个产品页有标题区和「产品介绍」能力卡片

**Independent Test**: `scripts/check-products-build.sh` 断言 #1、#2、#4、#9 通过；浏览器中从首页两次点击进入任一产品页并看懂产品是做什么的

- [X] T008 [US1] 在 `scripts/check-products-build.sh` 加断言 #1（首页 HTML 有 `dropdown-menu`，其中依次含 `/product/pp-writer/` 和 `/product/pp-runner/` 两个链接，文字分别为「小纸条（PP-Writer）」「跑步（PP-Runner）」）、#2（`$OUT/product/pp-writer/index.html`、`$OUT/product/pp-runner/index.html` 存在）、#4（两个产品页 `#intro` 区块内 `featurette-icon` 或 `<h3>` 卡片数在 3–6 之间）；执行确认三条 FAIL
- [X] T009 [US1] 在 `config/_default/languages.toml` 的 `[zh]` 下追加三个 `[[zh.menu.main]]`：父项「我的产品」（`identifier = "products"`，`weight = 4`，不设 `url`），子项「小纸条（PP-Writer）」→ `/product/pp-writer/`（weight 1）、「跑步（PP-Runner）」→ `/product/pp-runner/`（weight 2），子项都设 `parent = "products"`
- [X] T010 [P] [US1] 在 `config/_default/menus.toml` 追加与 T009 相同的三项（`[[main]]` 格式），保持两个文件一致
- [X] T011 [P] [US1] 新建 `content/product/pp-writer/index.md`（`title: "小纸条（PP-Writer）"`、`summary` 一句话定位、`type: widget_page`）和 `content/product/pp-writer/hero.md`（`widget = "hero"`、`headless`、`active`、`weight = 10`；标题为产品名，正文为一句话定位和支持平台；`cta` = 「了解下载」→ `#download`，`cta_alt` = 「看看新功能」→ `#whatsnew`）。定位文字依据 pp-cloud 中 pp-writer 的 spec（写作笔记 App：Markdown、文件夹、多工作区、Git 同步、桌面与手机），只写用户能感知的能力
- [X] T012 [P] [US1] 新建 `content/product/pp-writer/intro.md`（`widget = "featurette"`、`weight = 20`、`title = "产品介绍"`），`feature[]` 写 4–6 个核心能力（如 Markdown 实时渲染、文件夹与多工作区、跨设备同步、笔记加密、待办与收藏、搜索），每项 Font Awesome 图标 + 名称 + 一两句用户视角说明
- [X] T013 [P] [US1] 新建 `content/product/pp-runner/index.md`、`content/product/pp-runner/hero.md`，格式同 T011；定位依据 pp-cloud 中 pp-runner 的 spec（跑步记录 App：GPS 轨迹地图、配速与语音播报、天气、步数排行、锁屏显示、云端同步）
- [X] T014 [P] [US1] 新建 `content/product/pp-runner/intro.md`，格式同 T012，写 4–6 个跑步 App 核心能力
- [X] T015 [US1] 构建并执行 `scripts/check-products-build.sh "$OUT"`：#1、#2、#4、#9、#10 全部 PASS；对 `content/product` 执行 `scripts/check-public-content.sh` 退出码 0
- [X] T016 [US1] `hugo55 server` 人工检查：桌面下拉菜单、375px 宽度折叠菜单、明暗两种模式、hero 按钮锚点（此时 `#download`/`#whatsnew` 尚无区块，跳转无效属预期）

**Checkpoint**: US1 可单独上线（MVP）

---

## Phase 4: User Story 2 - 获取下载方式 (Priority: P2)

**Goal**: 产品页「下载」区块按平台显示内测状态和联系方式

**Independent Test**: 断言 #5 通过；小纸条显示 Android、macOS 两块，跑步只显示 Android，都没有下载按钮

- [X] T017 [US2] 在 `scripts/check-products-build.sh` 加断言 #5：两个产品页都有 `id="download"` 区块，区块内含「内测中，暂未开放下载」，且不含 `download-btn` 类的链接；执行确认 FAIL
- [X] T018 [US2] 新建 `layouts/partials/widgets/download.html`：参照主题 `themes/academic/layouts/partials/widgets/featurette.html` 的结构（`{{ $page := .page }}`、section-heading 标题），遍历 `$page.Params.platforms`，每个平台一张卡片：图标（`icon_pack` 默认 `fab`）、名称；`status` 为 `available` 且有 `url` 时显示版本号、更新日期和带 `download-btn` 类的「下载」按钮；否则显示 `note` 或默认「内测中，暂未开放下载」以及「联系我」链接（`/#about`）；只用 Bootstrap 4 已有的类，不写内联颜色，保证明暗模式自动适配
- [X] T019 [P] [US2] 新建 `content/product/pp-writer/download.md`（`widget = "download"`、`weight = 30`、`title = "下载"`），`platforms`：Android（`icon: android`）、macOS（`icon: apple`），都 `status: beta`，不写 `url`
- [X] T020 [P] [US2] 新建 `content/product/pp-runner/download.md`，`platforms` 只有 Android，`status: beta`
- [X] T021 [US2] 构建并执行断言脚本：#5 PASS 且之前的断言仍 PASS；浏览器检查两种模式和 375px 下卡片排版，hero 的「了解下载」按钮能跳到下载区块

**Checkpoint**: US1 + US2 可上线

---

## Phase 5: User Story 4 - 查看 Releases 详细版本说明 (Priority: P4，先于 US3 实施)

**Goal**: Releases 总入口、产品 Releases 列表页、发布详情页（Notion Releases 风格），先用每个产品 1 个手写样例验证

**Independent Test**: 打开 `/releases/pp-writer/` 看到按时间倒序的发布列表，点进样例发布看到全部功能小节和锚点

- [X] T022 [US4] 新建 `content/releases/_index.md`（`title: "Releases"`）、`content/releases/pp-writer/_index.md`（`title: "小纸条 Releases"`、`summary`、`product_page: /product/pp-writer/`）、`content/releases/pp-runner/_index.md`（同理）
- [X] T023 [P] [US4] 新建样例发布 `content/releases/pp-writer/2026-w41/index.md`：按 content-schema 第 4 节格式，`draft: true`，2–3 个 `items`（取 pp-cloud 最近一周已上线的 pp-writer 功能，按 R5 规则改写）
- [X] T024 [P] [US4] 新建样例发布 `content/releases/pp-runner/<最近一次有跑步功能上线的周>/index.md`，格式同 T023
- [X] T025 [US4] 新建 `layouts/releases/list.html`（`{{ define "main" }}`，与主题 `layouts/section/post.html` 的页面框架一致）：当前页是 `/releases/` 总入口时，列出各产品子区（`.Sections`）的标题、summary 和链接；是产品列表页时，顶部显示标题、summary 和「返回产品介绍」（`.Params.product_page`），下面按日期倒序列出 `.Pages`：每次发布显示日期、标题、summary、各 item 的分类标签 + summary，标题链接到详情页
- [X] T026 [US4] 新建 `layouts/releases/single.html`：显示标题、日期、summary、正文引言（`.Content`，可为空）；遍历 `.Params.items`，每项输出 `<section id="{{ .id }}">`，含分类标签、`summary` 作小标题、`detail | markdownify` 正文；有 `image` 时用 `$.Resources.GetMatch` 取同目录图片并 `Resize "960x"` 显示；底部「上一次 / 下一次发布」（同一产品区内，用 `.PrevInSection`/`.NextInSection`）和「返回 Releases 列表」（`.Parent.RelPermalink`）
- [X] T027 [P] [US4] 如列表/详情页需要额外样式：新建 `assets/css/custom.css`（分类标签颜色、发布卡片间距；暗色用 `.dark` 选择器覆盖），并在 `config/_default/params.toml` 把 `plugins_css = []` 改为 `plugins_css = ["custom"]`；不修改任何 `.scss`
- [X] T028 [US4] 用 `hugo55 -D` 构建：`/releases/`、`/releases/pp-writer/`、`/releases/pp-runner/` 和两个样例详情页都生成，详情页每个 item 都有对应 `id`；浏览器检查两种模式、375px、上一次/下一次链接；`scripts/check-public-content.sh` 退出码 0

**Checkpoint**: Releases 模板可用（样例仍为草稿，不会发布）

---

## Phase 6: User Story 3 - 浏览新功能 (Priority: P3)

**Goal**: 产品页「新功能」区块按时间倒序显示最近几次发布的摘要，每条链接到 Releases 详情页对应小节

**Independent Test**: 断言 #3、#6、#7、#8 通过

- [X] T029 [US3] 在 `scripts/check-products-build.sh` 加断言 #3（两个产品页依次出现 `id="intro"`、`id="download"`、`id="whatsnew"`）、#6（产品页中每个 `href="/releases/<product>/<slug>/#<id>"` 链接，对应的 `$OUT/releases/<product>/<slug>/index.html` 存在且含 `id="<id>"`）、#7（「新功能」区块含指向 `/releases/<product>/` 的「查看全部 Releases」链接，且目标页存在）、#8（pp-writer 产品页的 releases 链接全部以 `/releases/pp-writer/` 开头，pp-runner 同理）；用 `hugo55 -D` 构建执行，确认 FAIL
- [X] T030 [US3] 新建 `layouts/partials/widgets/release_notes.html`：读取 `$page.Params.product` 和 `count`（默认 5），取 `where site.RegularPages "Section" "releases"` 中 `.File.Dir` 以 `releases/<product>/` 开头的页面，按日期倒序取前 `count` 个；每次发布显示标题（链接详情页）和日期，下面每个 item 一行：分类标签 + `summary`，链接到 `<详情页 RelPermalink>#<id>`；末尾「查看全部 Releases」→ `/releases/<product>/`；没有任何发布时显示「即将更新」
- [X] T031 [P] [US3] 新建 `content/product/pp-writer/whatsnew.md`（`widget = "release_notes"`、`weight = 40`、`title = "新功能"`、`product = "pp-writer"`、`count = 5`）
- [X] T032 [P] [US3] 新建 `content/product/pp-runner/whatsnew.md`，`product = "pp-runner"`
- [X] T033 [US3] `hugo55 -D` 构建并执行断言脚本：全部断言 PASS；浏览器检查 hero「看看新功能」按钮、摘要链接落点、「查看全部 Releases」

**Checkpoint**: 功能全部可用，只差正式内容

---

## Phase 7: 内容整理（服务 US3 + US4）

**Purpose**: 按 research R4、R5 从 pp-cloud 整理全部发布，先作为草稿，站长审阅后发布

- [X] T034 [US4] 在 scratchpad（不进仓库）生成 pp-writer 素材清单：遍历 pp-cloud `docs/specs/` 中目录名含 `[pp-writer]` 的 spec，记录编号、标题、Status、上线日期（优先取对应 PR 合并提交日期 `git log --merges --grep`，否则 spec 的 `Created`）、ISO 周；按 R5 剔除未上线、纯脚本、调试、CI、签名证书类
- [X] T035 [P] [US4] 同 T034，生成 pp-runner 素材清单：目录名含 `[pp-runner]` 的 spec，加上无标签的 002–028 号中属于跑步 App 的（逐个读 spec 判断，纯 Web 后台的不收）
- [X] T036 [US4] 按 T034 清单，为 pp-writer 每个 ISO 周新建 `content/releases/pp-writer/<YYYY>-w<WW>/index.md`（`draft: true`）：起本周主题标题，写 1–3 句 summary；每个 spec 改写成一个 item（`id` 用英文短横线短语，`summary` ≤ 40 字，`detail` 2–4 句用户视角）；同周零碎修复合并为一个「若干稳定性改进」item；已有的样例周（T023）合并进来不重复
- [X] T037 [P] [US4] 按 T035 清单，同 T036 生成 `content/releases/pp-runner/` 下的全部发布
- [X] T038 [US4] 执行 `scripts/check-public-content.sh`（含本地敏感词表）直到退出码 0；`hugo55 -D` 构建后断言脚本全部 PASS
- [X] T039 [US4] **人工审阅关卡**：`hugo55 server -D` 下由站长逐条审阅两个产品的全部发布；按反馈修改；站长确认后把通过的文件 `draft: true` 改为 `draft: false`（未通过的保持草稿或删除）
- [X] T040 [US4] 不加 `-D` 构建（只含已发布内容），断言脚本全部 PASS，扫描脚本退出码 0

---

## Phase 8: Polish & Cross-Cutting

- [X] T041 [P] 更新 `CLAUDE.md`：补充产品页（`content/product/` widget page）、Releases（`content/releases/`、front matter `items` 是「新功能」与详情的单一来源）、两个检查脚本和本地敏感词表的说明，以及「站点生效的菜单在 `languages.toml`」
- [X] T042 按 `specs/001-my-products-menu/quickstart.md` 完整走一遍第 1–3 步并记录结果
- [X] T043 最终检查：`git status` 确认 `scripts/public-content-denylist.local.txt` 未被跟踪、`themes/academic/` 无改动、`resources/_gen/` 无删除；对将要提交的全部文件（含 `specs/`）执行一次扫描（`scripts/check-public-content.sh specs content/product content/releases`）
- [ ] T044 提交前向站长确认，push 到 `master` 后在 Netlify 查看构建日志（扫描步骤通过），并打开 https://flowerpp.com/product/pp-writer/ 、`/product/pp-runner/`、`/releases/pp-writer/` 确认线上效果

---

## Dependencies & Execution Order

### Phase 依赖

- **Setup (Phase 1)** → 无依赖
- **Foundational (Phase 2)** → 依赖 Phase 1（T002 词表）；**阻塞 Phase 5–7 的内容提交**，不阻塞 US1/US2
- **US1 (Phase 3)** → 依赖 T001；可与 Phase 2 并行
- **US2 (Phase 4)** → 依赖 US1（产品页 index.md 已存在）
- **US4 (Phase 5)** → 依赖 Phase 2；与 US1/US2 无文件冲突，可并行
- **US3 (Phase 6)** → 依赖 US4（T023–T026：样例数据和详情页锚点）和 US1（产品页）
- **内容整理 (Phase 7)** → 依赖 US3、US4 模板完成和 Phase 2 扫描脚本
- **Polish (Phase 8)** → 依赖全部完成

### 用户故事依赖

```text
US1 (P1) ──▶ US2 (P2)
   │
   └──────────────┐
Foundational ──▶ US4 (P4) ──▶ US3 (P3) ──▶ 内容整理 ──▶ Polish
```

### 可并行的任务

- Phase 1：T002、T003
- Phase 3：T010–T014（五个不同文件）
- Phase 4：T019、T020
- Phase 5：T023、T024、T027
- Phase 6：T031、T032
- Phase 7：T034 与 T035、T036 与 T037（两个产品互不影响）

## Parallel Example: User Story 1

```bash
# T009 完成后，同时进行：
Task: "T010 在 config/_default/menus.toml 追加相同三项"
Task: "T011 新建 content/product/pp-writer/index.md 和 hero.md"
Task: "T012 新建 content/product/pp-writer/intro.md"
Task: "T013 新建 content/product/pp-runner/index.md 和 hero.md"
Task: "T014 新建 content/product/pp-runner/intro.md"
```

## Implementation Strategy

### MVP（只做 US1）

1. Phase 1 → Phase 3（T001、T008–T016）
2. 验证：断言 #1、#2、#4、#9、#10 通过，浏览器检查通过
3. 可以先上线：导航有「我的产品」，两个产品页有介绍（hero 里跳到下载/新功能的按钮暂时无效，或上线前先去掉 `cta`）

### 增量交付

1. US1 → 上线（MVP）
2. US2 → 上线（产品页有下载区块）
3. Phase 2 + US4 + US3 → 模板就绪，样例为草稿，上线不会暴露内容
4. 内容整理 + 人工审阅 → 上线完整的新功能和 Releases

每一步都要求断言脚本全部 PASS、扫描脚本退出码 0。
