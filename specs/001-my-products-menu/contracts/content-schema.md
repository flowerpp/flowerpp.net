# Contract: 内容文件格式

模板（`layouts/`）和内容（`content/`）之间的约定。以后加内容只改 `content/`，不改模板。front matter 统一用 YAML（与现有博文一致），区块文件沿用 Academic 示例的 TOML 也可以，两种 Hugo 都能读。

## 1. 产品页 `content/product/<product>/index.md`

```yaml
---
title: "小纸条（PP-Writer）"        # 页面标题，同时用于浏览器标签
summary: "一句话定位"               # 用于 SEO 描述和分享卡片
type: widget_page                   # 必填：按区块渲染
---
```

## 2. 区块文件（与 index.md 同目录）

| 文件 | `widget` | `weight` | 页内锚点 | 说明 |
|------|----------|----------|----------|------|
| `hero.md` | `hero`（主题自带） | 10 | `#hero` | 产品名 + 一句话定位；`cta` → `/product/<product>/#download`，`cta_alt` → `/product/<product>/#whatsnew`（必须写完整路径：主题会对链接做 `relLangURL`，只写 `#download` 会变成首页的 `/#download`） |
| `intro.md` | `featurette`（主题自带） | 20 | `#intro` | `title: 产品介绍`；`feature[]` 3–6 项 |
| `download.md` | `download`（新增） | 30 | `#download` | 见下 |
| `whatsnew.md` | `release_notes`（新增） | 40 | `#whatsnew` | 见下 |

所有区块必须 `headless: true`、`active: true`。

### `intro.md` 的 `feature[]`（主题 featurette 原有格式）

```yaml
feature:
  - icon: pen            # Font Awesome 5 图标名
    icon_pack: fas
    name: "Markdown 写作"
    description: "一两句话，用户视角"
```

### `download.md`（新增 widget）

```yaml
---
widget: download
headless: true
active: true
weight: 30
title: "下载"
releases_url: https://github.com/flowerpp/pp-releases/releases   # 可选，区块底部「查看全部版本」
platforms:
  - name: "Android"          # 必填
    icon: android            # 可选，Font Awesome 图标名（icon_pack 默认 fab）
    status: beta             # 必填：beta = 内测中；available = 可下载
    version: "1.0.0"         # 可选
    updated: 2026-10-11      # 可选
    url: ""                  # status = available 时必填；beta 时必须为空
    size: "5.5 MB"           # 可选，文件大小
    note: ""                 # 可选，覆盖默认说明文字
---
```

渲染规则：
- `status: beta` → 显示「内测中，暂未开放下载」（或 `note`），以及「联系我」链接（`/#about`）；不显示下载按钮。
- `status: available` → 显示版本号、更新日期、文件大小和「下载」按钮（`url`），`note` 作为安装提示显示在按钮下方。
- 安装包发布在 GitHub 仓库 `flowerpp/pp-releases` 的 Releases；更新版本时改 `version`、`updated`、`size`、`url` 四个字段。

### `whatsnew.md`（新增 widget）

```yaml
---
widget: release_notes
headless: true
active: true
weight: 40
title: "新功能"
product: pp-writer      # 必填：读取 content/releases/<product>/ 下的发布
count: 5                # 可选：显示最近几次发布，默认 5
---
```

渲染规则：按日期倒序取 `count` 次已发布（非草稿）的 Release；每次显示标题和日期，下面每个 item 一行 `[分类] summary`，链接到 `<Release 页>#<item.id>`；末尾是「查看全部 Releases」→ `/releases/<product>/`。

## 3. 产品 Releases 列表 `content/releases/<product>/_index.md`

```yaml
---
title: "小纸条 Releases"
summary: "小纸条（PP-Writer）的每一次更新"
product_page: /product/pp-writer/     # 列表页顶部「返回产品介绍」链接
---
```

## 4. 单次发布 `content/releases/<product>/<YYYY>-w<WW>/index.md`

```yaml
---
title: "笔记加锁与桌面待办"           # 本周主题
date: 2026-10-09                     # 本周最后一个功能的上线日期
summary: "一段 1–3 句的概述"          # 列表页显示
draft: true                          # 整理时一律 true，审阅后改 false
items:
  - id: note-lock                    # 必填，[a-z0-9-]，本次发布内唯一
    category: 新功能                  # 必填：新功能 | 改进 | 修复
    summary: "笔记可以加密锁定"        # 必填，≤ 40 字，用于产品页「新功能」
    detail: |                        # 必填，Markdown，2–4 句，用于详情页
      为私密笔记设置密码……
    image: note-lock.png             # 可选，与 index.md 同目录的图片（一张）
    images: [home.png, home-dark.png] # 可选，多张并排；与 image 可同时用
---
```

正文（front matter 之后）可以为空；如果有内容，显示在各功能小节之前作为引言。

详情页渲染：标题、日期、概述，然后每个 item 一节（`<section id="<id>">`，小标题为 `summary`，带分类标签，正文为 `detail`，有 `image` / `images` 时配图：宽于 960px 才缩小，竖图按 240px 宽显示，多张并排），底部「上一次 / 下一次发布」和「返回 Releases 列表」。
