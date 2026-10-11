# Quickstart: 验证「我的产品」栏目

**相关文档**：[contracts/check-scripts.md](./contracts/check-scripts.md)（断言清单）、[contracts/urls-and-menu.md](./contracts/urls-and-menu.md)（网址）、[contracts/content-schema.md](./contracts/content-schema.md)（内容格式）

## 前提

- 在仓库根目录执行；使用 `hugo55`（v0.55.6），**不要用 `hugo`，构建不要加 `--gc`**
- 如需检查具体敏感词，先在本地准备 `scripts/public-content-denylist.local.txt`（不提交）

## 1. 内部信息扫描（包括草稿）

```bash
bash scripts/check-public-content.sh
```

期望：退出码 0，最后一行显示扫描的文件数、命中 0 条；本地词表存在时不出现「未加载本地敏感词表」提示。

反向验证（确认脚本真的会拦截）：

```bash
mkdir -p /tmp/leak && printf -- '---\ntitle: x\n---\n服务器 10.1.2.3\n' > /tmp/leak/index.md
bash scripts/check-public-content.sh /tmp/leak; echo "exit=$?"   # 期望 exit=1，并指出 10.1.2.3
```

## 2. 构建并做结构断言

```bash
OUT=$(mktemp -d)
hugo55 -d "$OUT"                                  # 期望：无 ERROR
bash scripts/check-products-build.sh "$OUT"       # 期望：10 条全部 PASS，退出码 0
```

草稿审阅阶段用 `hugo55 -D -d "$OUT"`，把 `draft: true` 的发布也算进去。

## 3. 浏览器人工检查

```bash
hugo55 server -D        # http://localhost:1313
```

| 检查 | 期望 |
|------|------|
| 任意页面顶部导航 | 有「我的产品」，展开后依次是「小纸条（PP-Writer）」「跑步（PP-Runner）」 |
| 点进小纸条 | 顶部是产品名和一句话定位，下面依次是产品介绍（能力卡片）、下载、新功能；顶部按钮能跳到「下载」「新功能」 |
| 下载 | Android、macOS 两块，都显示「内测中，暂未开放下载」和联系方式，没有下载按钮 |
| 新功能 | 按时间倒序，每条点进去落到 Releases 详情页的对应小节；底部「查看全部 Releases」 |
| Releases 列表 / 详情 | 按时间倒序；详情页每节有小标题、分类、说明；有上一次/下一次和返回列表 |
| 跑步产品页 | 同上，下载只有 Android，新功能里没有小纸条的内容 |
| 宽度 375px（开发者工具手机模式） | 菜单折叠后仍能点开「我的产品」；没有横向滚动 |
| 右上角切换明暗模式 | 两种模式下文字和卡片都清晰可读 |
| 首页、博客、关于 | 与改动前一致 |

## 4. 发布前

1. 所有要发布的 release 文件逐条人工审阅，把 `draft: true` 改为 `false`
2. 重新执行第 1、2 步
3. 提交、push 到 `master` → Netlify 构建（构建命令最前面会再跑一次第 1 步的通用扫描，命中就不发布）
4. 打开 https://flowerpp.com/product/pp-writer/ 确认线上效果
