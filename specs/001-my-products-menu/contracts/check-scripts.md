# Contract: 检查脚本

两个 Bash 脚本，零依赖（只用 bash、grep、find），macOS 和 Netlify 的 Linux 上都能跑。

## `scripts/check-public-content.sh` — 内部信息扫描

```text
用法: scripts/check-public-content.sh [目录...]
  默认扫描 content/product 和 content/releases
退出码: 0 = 没有命中；1 = 有命中；2 = 用法错误或禁止模式文件缺失
输出: 每个命中一行  <文件>:<行号>: <命中的模式>  ；最后一行汇总
```

- 禁止模式分两个文件，格式相同：每行一个扩展正则（`grep -E`），`#` 开头为注释。
  - `scripts/public-content-denylist.txt`（**提交进仓库**）：只放**通用模式**，本身不含任何敏感词：IPv4 地址、`localhost`、`内网`、`内部`、`\.sh\b`、`\.py\b`、`token`、`密钥`、`证书`、`keychain`、`password`、邮箱格式。
  - `scripts/public-content-denylist.local.txt`（**不提交**，加入 `.gitignore`）：放**具体敏感词**：pp-cloud 里出现过的内部域名、主机名、公司/项目代号、真实姓名。仓库是公开的，这些词写进提交的文件就等于公开了。
  - 本地文件存在就一起用；不存在（如 Netlify 上）只用通用模式，并在输出里提示「未加载本地敏感词表」。
- 草稿（`draft: true`）同样扫描，避免审阅时才发现。
- 接入 Netlify：三条构建命令最前面加 `bash scripts/check-public-content.sh &&`，命中就构建失败、不发布。

## `scripts/check-products-build.sh` — 构建结果断言

```text
用法: scripts/check-products-build.sh <构建输出目录>
  先自行运行: hugo55 -d <目录>   （不要加 --gc）
退出码: 0 = 全部通过；1 = 有断言失败
输出: 每条断言一行 PASS/FAIL + 说明
```

断言清单（对应 spec）：

| # | 断言 | 对应 |
|---|------|------|
| 1 | 首页导航含「我的产品」下拉，且依次含两个子项链接 | FR-001、SC-001 |
| 2 | `/product/pp-writer/`、`/product/pp-runner/` 存在 | FR-002 |
| 3 | 两个产品页都含 `id="intro"`、`id="download"`、`id="whatsnew"`，且按此顺序出现 | FR-003、SC-002 |
| 4 | 两个产品页的 featurette 卡片数在 3–6 之间 | FR-005 |
| 5 | 下载区块里不存在任何下载按钮链接（当前全部是内测） | FR-006、Q2 |
| 6 | 「新功能」中每个指向 `/releases/...#id` 的链接，在对应 release 页里都能找到 `id="<id>"` | FR-013、SC-002 |
| 7 | 「新功能」中有「查看全部 Releases」链接，且目标列表页存在 | FR-013 |
| 8 | pp-writer 产品页的「新功能」链接全部指向 `/releases/pp-writer/`，pp-runner 同理 | User Story 3 场景 3 |
| 9 | 首页仍含原有「最新博文」和「关于」区块，原有三个菜单项链接不变 | FR-011、SC-005 |
| 10 | 页面中没有幕布（`mubu.com`）链接 | FR-004 |
