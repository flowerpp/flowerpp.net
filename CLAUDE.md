# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

flowerpp 的个人网站（博客），基于 Hugo + Academic 主题（v4.4.0）的静态站点，站点语言为中文（`zh`）。

- 远程仓库：`github.com/flowerpp/flowerpp.net`（分支 `master`）
- 线上地址：https://flowerpp.com/（私人域名，主域名）、https://flowerpp.netlify.app/（Netlify 默认域名）
- 发布方式：push 到远程 `master` 后，Netlify 自动构建并发布（配置见 `netlify.toml`）。没有其他部署脚本，也没有测试或 lint。

## 常用命令

```bash
hugo55 server                  # 本地预览，默认 http://localhost:1313
hugo55 server -D               # 预览时包含草稿（draft: true）
hugo55 new post/<slug>/index.md   # 新建博文（page bundle 形式）
```

### Hugo 版本（重要）

- **必须用 `hugo55`**（`/Users/flowerpp/work/tools/hugo55/hugo55`，v0.55.6），与 Netlify 上的 `HUGO_VERSION = "0.55.6"` 一致。
- PATH 里的 `hugo` 是 v0.123，**跑不起来本站**：Academic 4.4 模板与新版不兼容，而且 `layouts/partials/site_footer.html` 里的 `getenv "BUILD_TIME"` 会被新版 Hugo 的 `security.funcs.getenv` 策略拦截。
- 本地构建**不要加 `--gc`**：`resources/_gen/` 已经提交进 git（尽管 `.gitignore` 里写了 `resources/`），`--gc` 会删掉这些已跟踪的缓存文件。万一删了，用 `git checkout -- resources/` 恢复。
- `public/` 是构建产物，已加入 `.gitignore`。

## 架构与配置要点

### 配置文件有两套
- 根目录 `config.toml`（`hasCJKLanguage = true`）
- `config/_default/` 目录（`config.toml`、`params.toml`、`menus.toml`、`languages.toml`）

Hugo 会合并两者，且**根目录 `config.toml` 优先**。两处 baseurl 都设为 `https://flowerpp.com/`，修改时要同时改；Netlify 生产构建时会用 `-b $URL` 覆盖 baseurl（`$URL` 是站点在 Netlify 上设置的主域名）。改站点参数前，先确认改的是实际生效的那个文件。主题外观、`day_night`、`reading_time` 等参数在 `config/_default/params.toml`；`theme = "flowerpp"` 对应 `data/themes/flowerpp.toml`（自定义配色）。

### 主题是直接拷贝进仓库的
`themes/academic/` 是直接 vendored 的主题源码，不是 git submodule。**不要直接改主题文件**；要定制就把对应模板复制到根目录 `layouts/` 下覆盖（Hugo 的查找顺序是根目录 `layouts/` 优先于主题）。当前已覆盖的：
- `layouts/partials/site_footer.html`：页脚加了 “Last update”，显示 `BUILD_TIME` 环境变量（Netlify 的 build command 会设置成北京时间）
- `layouts/partials/page_metadata.html`
- `i18n/zh.yaml`：中文文案覆盖

### 首页由 widget 拼装
`content/home/` 下每个 `.md` 是一个首页区块（headless widget），用 front matter 控制：`widget` 类型、`active` 开关、`weight` 排序。目前启用的是 `posts.md`（最新博文，weight 10）和 `about.md`（关于，weight 20）。导航菜单（`config/_default/menus.toml`）的 `#posts`、`#about` 锚点就对应这些 widget 的文件名。

### 内容
- 博文放在 `content/post/<slug>/index.md`（page bundle，封面图命名为 `featured.jpg`）。front matter 用 YAML，常用字段：`title`、`date`（带 `+08:00` 时区）、`draft`、`tags`、`categories`。
- 个人信息和 About 内容在 `content/authors/admin/_index.md`（头像是同目录下的 `avatar.png`）。
- `content/` 下的 `project`、`publication`、`talk`、`courses`、`slides` 等大多是 Academic 自带的示例内容，首页没有启用。

## 其他
- `.specify/`、`.claude/skills/speckit-*` 是 Spec Kit 工具链文件（还没提交）；`.specify/memory/constitution.md` 目前还是未填写的模板。
