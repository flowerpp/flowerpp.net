# Implementation Plan: 我的产品栏目（小纸条 PP-Writer / 跑步 PP-Runner）

**Branch**: `001-my-products-menu` | **Date**: 2026-10-11 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/001-my-products-menu/spec.md`

## Summary

在网站导航新增「我的产品」下拉菜单，为小纸条和跑步两个产品各做一个产品页（产品介绍 / 下载 / 新功能三个区块）和一个 Releases 栏目（Notion Releases 式的详细发布说明）。实现方式：

- **菜单**：用 Academic 主题原生的下拉菜单，配置写在实际生效的 `languages.toml`（R1）。
- **产品页**：用 Academic 的 widget page，「产品介绍」用主题自带的 featurette 卡片，「下载」和「新功能」新增两个小 widget 模板（R2、R7）。
- **Releases**：新增 `releases` 内容区和列表/详情两个模板，每次发布按周合并，功能小节写在 front matter 里。产品页「新功能」读的是同一份数据，所以摘要和详情始终一致（R3、R4）。
- **内容来源**：Claude 读 pp-cloud 中已上线的 `[pp-writer]`/`[pp-runner]` spec，改写成面向用户的条目，一律先作为草稿，站长审阅后发布（R5）。
- **防泄露**：人工审阅 + 扫描脚本。脚本接入 Netlify 构建，命中就不发布；具体敏感词只放在不提交的本地文件里（R6）。

## Technical Context

**Language/Version**: Hugo 0.55.6 extended（本地 `hugo55`，Netlify 构建命令自行下载）；Go template；Markdown + YAML front matter；Bash（检查脚本）

**Primary Dependencies**: 仓库内 vendored 的 Academic 4.4.0 主题（Bootstrap 4、Font Awesome 5），不新增任何依赖

**Storage**: N/A（内容即文件）

**Testing**: `hugo55` 构建 0 错误 + `scripts/check-products-build.sh`（对构建产物做 grep 断言）+ `scripts/check-public-content.sh`（内部信息扫描）+ 浏览器人工检查（见 quickstart.md）

**Target Platform**: 静态网站，Netlify 托管（flowerpp.com / flowerpp.netlify.app），桌面和手机浏览器

**Project Type**: 静态网站（Hugo）

**Performance Goals**: 与现有页面相当；产品页不引入额外脚本，图片可选且使用 Hugo 图像处理缩放

**Constraints**:
- 必须兼容 Hugo 0.55.6（不能用 0.55 之后的模板函数和特性）
- 不修改 `themes/academic/`，只在根目录 `layouts/` 新增/覆盖
- 本地构建不加 `--gc`（`resources/_gen/` 已提交进 git）
- 仓库是公开的：提交的任何文件（包括 specs 和禁止模式文件）都不能含内部信息

**Scale/Scope**: 2 个产品页、2 个 Releases 列表、约 20–50 个发布页；新增约 6 个模板/脚本文件

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

`.specify/memory/constitution.md` 还是未填写的模板，没有项目治理原则，所以没有可检查的条款。改用 `CLAUDE.md` 里记录的项目约束作为关卡：

| 关卡 | Phase 0 前 | Phase 1 设计后 |
|------|-----------|----------------|
| 只用 hugo55，兼容 Hugo 0.55.6 | ✅ 所有方案都在 hugo55 上实测过 | ✅ 未用新版特性（无 content adapter、无 render hook） |
| 不改 `themes/academic/`，用根目录 `layouts/` 覆盖 | ✅ | ✅ 只新增 `layouts/releases/*`、`layouts/partials/widgets/{download,release_notes}.html` |
| 构建不加 `--gc` | ✅ | ✅ quickstart 和检查脚本都不用 `--gc` |
| 不影响现有首页/博客/关于 | ✅ | ✅ 菜单只追加；check-products-build 断言 #9 |
| 公开仓库不含内部信息 | ✅ | ✅ 敏感词表放在不提交的本地文件；specs 已扫描，无内部信息 |

结论：通过，没有需要说明理由的违反项。

## Project Structure

### Documentation (this feature)

```text
specs/001-my-products-menu/
├── plan.md              # 本文件
├── research.md          # Phase 0：R1–R8 技术决策
├── data-model.md        # Phase 1：实体、关系、校验规则
├── quickstart.md        # Phase 1：验证步骤
├── contracts/
│   ├── content-schema.md   # 内容文件 front matter 格式
│   ├── urls-and-menu.md    # 对外网址与菜单配置
│   └── check-scripts.md    # 两个检查脚本的用法与断言清单
├── checklists/requirements.md
└── tasks.md             # Phase 2（/speckit-tasks 生成）
```

### Source Code (repository root)

```text
config/_default/
├── languages.toml               # 改：追加「我的产品」及两个子菜单（实际生效）
├── menus.toml                   # 改：同步追加，保持两处一致
└── params.toml                  # 改（如需样式）：plugins_css = ["custom"]

content/
├── product/
│   ├── pp-writer/
│   │   ├── index.md             # type: widget_page
│   │   ├── hero.md              # 主题 hero
│   │   ├── intro.md             # 主题 featurette：产品介绍
│   │   ├── download.md          # 新 widget：下载
│   │   └── whatsnew.md          # 新 widget：新功能
│   └── pp-runner/               # 同上
└── releases/
    ├── _index.md                # Releases 总入口
    ├── pp-writer/
    │   ├── _index.md
    │   └── 2026-w41/index.md …  # 每周一次发布（初始为草稿）
    └── pp-runner/
        └── …

layouts/
├── partials/widgets/
│   ├── download.html            # 新增
│   └── release_notes.html       # 新增
└── releases/
    ├── list.html                # 新增：Releases 总入口 + 产品列表页
    └── single.html              # 新增：发布详情页

assets/css/custom.css            # 新增（如需）：Releases/下载样式；在 config/_default/params.toml 设 plugins_css = ["custom"] 加载；暗色用 `.dark` 选择器适配
                                 # 不改 sass：改 main.scss 会让已提交的 resources/_gen 缓存失效

scripts/
├── check-public-content.sh      # 新增
├── public-content-denylist.txt  # 新增：通用禁止模式（提交）
└── check-products-build.sh      # 新增

netlify.toml                     # 改：三条构建命令前面加内部信息扫描
.gitignore                       # 改：加 scripts/public-content-denylist.local.txt
```

**Structure Decision**: 沿用现有 Hugo 站点结构，新内容放在 `content/product/` 和 `content/releases/`，新模板放在根目录 `layouts/` 覆盖层，检查脚本放在新建的 `scripts/` 目录。

## 实施顺序（供 /speckit-tasks 拆分）

1. **US1（P1）**：菜单 + 两个产品页的 hero 和产品介绍 → 可单独上线
2. **US2（P2）**：download widget + 两个下载区块
3. **防泄露基础**：扫描脚本、通用词表、`.gitignore`、接入 Netlify（必须在任何新功能/Releases 内容提交之前完成）
4. **US4 模板（P4）**：releases 列表/详情模板，先用 1 个手写样例发布验证
5. **US3（P3）**：release_notes widget，读取样例发布
6. **内容整理**：从 pp-cloud 整理全部发布（草稿）→ 站长审阅 → 改为发布
7. **收尾**：check-products-build.sh、quickstart 全流程、更新 CLAUDE.md（新增的内容结构和脚本）

US3 依赖 US4 的数据结构，所以先做 Releases 模板，再做「新功能」摘要。

## Complexity Tracking

无违反项，不需要填写。
