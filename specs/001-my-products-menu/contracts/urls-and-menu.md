# Contract: 对外网址与导航菜单

这些网址会被分享出去，定下来后不再改（FR-002、FR-012）。

## 网址

| 页面 | 网址 |
|------|------|
| 小纸条产品页 | `/product/pp-writer/` |
| 跑步产品页 | `/product/pp-runner/` |
| 产品页三个部分 | `/product/<product>/#intro`、`#download`、`#whatsnew` |
| 小纸条 Releases 列表 | `/releases/pp-writer/` |
| 跑步 Releases 列表 | `/releases/pp-runner/` |
| 单次发布 | `/releases/<product>/<YYYY>-w<WW>/` |
| 发布中的某个功能 | `/releases/<product>/<YYYY>-w<WW>/#<item.id>` |
| Releases 总入口 | `/releases/`（列出两个产品，不进导航） |

## 导航菜单

写在 `config/_default/languages.toml` 的 `[[zh.menu.main]]`（**站点实际生效的是这里**，`menus.toml` 被覆盖，见 research R1）。

```toml
  [[zh.menu.main]]
    name = "我的产品"
    identifier = "products"
    weight = 4                 # 排在「关于」(3) 之后

  [[zh.menu.main]]
    name = "小纸条（PP-Writer）"
    parent = "products"
    url = "/product/pp-writer/"
    weight = 1

  [[zh.menu.main]]
    name = "跑步（PP-Runner）"
    parent = "products"
    url = "/product/pp-runner/"
    weight = 2
```

现有「首页 / 博客 / 关于」三项不动（FR-011）。`config/_default/menus.toml` 同步加上相同的三项，保证两处一致，免得以后有人改了不生效的那个文件。
