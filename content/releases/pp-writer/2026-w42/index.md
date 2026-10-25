---
title: "图片：插入、粘贴与右键操作"
date: 2026-10-15
summary: "笔记里的图片好用多了：手机上能插入图片，图片可以右键或长按剪切、复制、删除；Git 同步也更可靠。"
draft: false
items:
  - id: app-insert-image
    category: 新功能
    summary: "手机端插入图片"
    detail: |
      App 里可以从相册插入图片，渲染模式下立即显示出来。
  - id: image-actions
    category: 新功能
    summary: "图片右键 / 长按菜单"
    detail: |
      参考 Typora：在 Mac 版右键图片、在手机上长按图片，会同时选中图片和它的 Markdown 源码，可以剪切、复制、复制图片、粘贴或删除。Mac 版还能「打开图片位置」。

      删除的图片会进回收站，可以恢复；某个图片文件夹空了之后也会一并清理掉。
  - id: copy-path
    category: 新功能
    summary: "复制笔记路径"
    detail: |
      Mac 版笔记菜单里，「在 Finder 中显示」后面新增「复制路径」，一键复制笔记文件的完整路径。
  - id: git-sync
    category: 改进
    summary: "Git 同步更可靠"
    detail: |
      - 同步被意外中断留下的残留状态会自动清理，不会再一直提示「同步失败：未知错误」
      - 多台设备同时推送撞车时会自动重试；真的失败时如实提示，不会再误报「同步成功」
  - id: stability
    category: 修复
    summary: "若干问题修复"
    detail: |
      - 修复 Mac 版切回工作区时提示「找不到这篇笔记」的问题
      - 光标位置记录得更准，同时打开多个窗口也不会互相覆盖
---
