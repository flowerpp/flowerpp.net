# Data Model: 我的产品栏目

**Feature**: [spec.md](./spec.md) | **Research**: [research.md](./research.md)

静态站点没有数据库，「数据」就是 Hugo 内容文件的 front matter。下面每个实体对应一种文件，字段格式见 [contracts/content-schema.md](./contracts/content-schema.md)。

## 实体与文件对应

| 实体 | 文件 | 数量 |
|------|------|------|
| 产品（Product） | `content/product/<product>/index.md` + 同目录区块文件 | 2（`pp-writer`、`pp-runner`） |
| 下载项（Download） | `content/product/<product>/download.md` 的 `platforms[]` | 小纸条 2（Android、macOS），跑步 1（Android） |
| 产品 Releases 列表 | `content/releases/<product>/_index.md` | 每个产品 1 个 |
| 发布（Release） | `content/releases/<product>/<YYYY>-w<WW>/index.md` | 每个产品约 10–25 个 |
| 功能小节（Release Item） | Release 文件 front matter 的 `items[]` | 每次发布 1–8 条 |

## 关系

```text
Product (pp-writer)
 ├── Download × N              （download.md 的 platforms[]）
 └── Releases 列表 (_index.md)
      └── Release × N          （按周，slug = 2026-w41）
           └── Release Item × N（items[]，各有 id）
                ├── summary → 产品页「新功能」中的一行，链接到 Release 页 #id
                └── detail  → Release 详情页中的一节
```

产品与 Releases 的关联靠**目录名一致**：`content/product/pp-writer/` ↔ `content/releases/pp-writer/`。

## 校验规则（来自 spec）

| 规则 | 来源 | 由谁检查 |
|------|------|----------|
| 每个产品页恰好有 `intro`、`download`、`whatsnew` 三个区块，按此顺序（weight 递增） | FR-003 | `check-products-build.sh` |
| `intro` 的 `feature[]` 有 3–6 项 | FR-005 | `check-products-build.sh` |
| 每个 `platforms[]` 项有 `name`、`status`；`status` 为 `beta` 时不能有 `url` | FR-006、Q2 | `check-products-build.sh` |
| Release 的 `items[].id` 在同一次发布内唯一，只含 `[a-z0-9-]` | FR-013 | `check-products-build.sh` |
| `items[].category` 只能是 `新功能` / `改进` / `修复` | Key Entities | `check-products-build.sh` |
| `items[].summary` 不超过 40 个字；`detail` 不为空 | FR-007、FR-014 | 人工审阅 |
| 产品页和 Releases 的全部文字不命中禁止模式 | FR-008、SC-003 | `check-public-content.sh` + 人工审阅 |
| 一个 Release 只属于一个产品（由所在目录决定），不混入另一个产品的条目 | User Story 3 场景 3 | 整理时保证；目录结构天然隔离 |

## 状态

Release 没有复杂状态，只用 Hugo 自带的 `draft`：

```text
草稿 (draft: true) ──站长审阅通过──▶ 已发布 (draft: false)
```

整理阶段生成的 release 文件一律先是 `draft: true`，本地用 `hugo55 server -D` 预览；审阅通过后改为 `false` 再提交。
