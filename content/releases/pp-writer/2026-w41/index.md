---
title: "收藏书签栏与标题自动同步文件名"
date: 2026-10-11
summary: "桌面版有了像浏览器一样的收藏书签栏；改笔记标题时文件名自动跟着改；Tab 缩进、插入日期都可以自己设置。打开大文件夹也快多了。"
draft: false
items:
  - id: favorites-bar
    category: 新功能
    summary: "收藏书签栏"
    detail: |
      常用笔记可以固定在中栏顶部，像浏览器的书签栏一样一键打开。搜索框移到了左栏收藏的上方。

      收藏名显示几个字也可以在设置里调整。
  - id: title-filename-sync
    category: 新功能
    summary: "标题改了，文件名自动跟着改"
    detail: |
      在第一行用 `# 标题` 写标题时，自动保存会同时把文件名改成标题（默认取前 20 个字，自动去掉文件名里不能用的字符）。

      截取字数和要去掉的字符都可以在设置里调整，设置跟着账号走，手机和电脑一致。
  - id: insert-date
    category: 新功能
    summary: "快捷键插入日期"
    detail: |
      在设置里配置快捷键和日期格式，一按就插入今天的日期；还可以插入「本周」这类日期范围（如 `20261008-1009`），写周报更方便。
  - id: indent-settings
    category: 新功能
    summary: "Tab 缩进与换行保持缩进"
    detail: |
      按 Tab 插入缩进，默认 2 个空格，宽度和是否用空格代替 Tab 都可以设置；回车换行时自动保持上一行的缩进。

      手机端会使用你账号里的同一套设置，行首空格也按等宽显示，缩进对得更整齐。
  - id: root-menu
    category: 改进
    summary: "「我的文档」也能直接新建"
    detail: |
      鼠标移到左栏「我的文档」上会出现「⋯」菜单，可以直接新建笔记或文件夹，和子文件夹的操作一致。
  - id: info-line-col
    category: 改进
    summary: "信息面板显示行、列与文件编码"
    detail: |
      编辑区右上角的信息弹窗里，新增了当前光标所在的行、列，以及文件编码。
  - id: text-file-types
    category: 改进
    summary: "工作区可以显示其他文本文件"
    detail: |
      除了 Markdown 笔记，工作区里的其他纯文本文件也能显示和编辑，支持哪些文件类型可以按工作区设置。
  - id: pinned-save-status
    category: 改进
    summary: "保存状态固定在编辑区顶部"
    detail: |
      「已保存」的提示固定显示在编辑区顶栏，不再随正文滚动，长笔记写到最后也能看到；保存失败时会变红提醒。
  - id: large-workspace
    category: 改进
    summary: "打开大文件夹快多了"
    detail: |
      把一个文件很多的大文件夹作为工作区打开时，速度明显提升。
  - id: safe-save
    category: 改进
    summary: "同一工作区开两个窗口也不会丢内容"
    detail: |
      同一个工作区被两个小纸条同时打开时，保存会互相避让并给出提示，不会再出现笔记「找不到了」或光标跳回开头的情况。
  - id: stability
    category: 修复
    summary: "若干稳定性改进"
    detail: |
      - 修复正式版启动后显示未登录、需要重新登录的问题
      - 编辑区右侧留白恢复为与左侧一致
      - 只同步由小纸条克隆或登记为 Git 的工作区，避免误同步本地文件夹
---
