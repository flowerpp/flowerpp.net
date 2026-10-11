---
title: "跑步数据零丢失"
date: 2026-08-30
summary: "这一周集中解决跑步数据的可靠性：没传上去的跑步能看到、能重传，GPS 距离也更准了。"
draft: false
items:
  - id: pending-runs
    category: 新功能
    summary: "待上传的跑步能看到、能重传"
    detail: |
      因为网络等原因还没上传成功的跑步记录会单独列出来，可以打开查看，也可以手动重传，不会悄悄丢失。
  - id: cloud-only
    category: 改进
    summary: "登录后跑步数据直接存云端"
    detail: |
      登录用户跑完步数据立刻保存到云端，详情直接从云端读取；保存失败会明确提示。
  - id: gps-accuracy
    category: 改进
    summary: "GPS 距离更准确"
    detail: |
      优化了定位采样，并用速度信息判断是否在移动：等红灯时距离不会乱跳，信号弱时距离不再虚高。
  - id: stability
    category: 修复
    summary: "修复跑完记录偶尔丢失"
    detail: |
      修复了上传失败时跑步记录可能永久丢失的问题。
---
