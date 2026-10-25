---
title: "PP-Runner 全新改版"
date: 2026-10-18
summary: "从首页、跑前设置、跑步中到跑完结算，整个 App 按全新设计重做：新的配色和数字字体、支持深色模式，跑步中有阶段配速和语音播报，跑完先看结算，还有年度目标和个人最佳。"
draft: false
items:
  - id: new-look
    category: 新功能
    summary: "全新配色与深色模式"
    detail: |
      全 App 换上统一的新配色和更清晰的数字字体。外观可以选「跟随系统 / 浅色 / 深色」，打开 App 的第一眼就是你选的外观。
    images:
      - home.png
      - home-dark.png
  - id: run-setup
    category: 新功能
    summary: "跑前设置：自由跑或目标跑"
    detail: |
      开跑前可以选择自由跑，或者设定距离 / 时间目标（1、3、5、10 公里、半马、全马或自定义），并按你的平均配速预估用时。页面底部显示 GPS 是否就绪，就绪时手机会轻轻振动。
    images:
      - run-setup.png
  - id: running
    category: 新功能
    summary: "跑步中：三种配速与阶段配速图"
    detail: |
      跑步中同时显示时间、距离和平均 / 实时 / 阶段三种配速，下方是每 500 米一段的阶段配速柱状图，设了目标还会显示进度。可以一键锁屏防误触，暂停、继续、完成都在手边。
    images:
      - running.png
  - id: voice
    category: 新功能
    summary: "跑步语音播报"
    detail: |
      每跑完一公里、每完成一个阶段、达成目标时都会语音播报，播报内容、提示音量和语音包都可以在跑步设置里调整。
  - id: notification
    category: 新功能
    summary: "通知栏随时看、随时控"
    detail: |
      跑步中的通知栏和锁屏通知改了新样式，直接显示距离、时间和配速，可以在通知里暂停、继续；GPS 信号弱时也会提示。
    images:
      - notification.png
  - id: summary
    category: 新功能
    summary: "跑完先看结算"
    detail: |
      跑完马上进入结算页：本次距离、时长、配速、卡路里，和上一次比快了多少，本月累计跑了多少，以及每公里的配速分段。记录先存在手机上，后台自动上传，网络差也不用干等。
    images:
      - summary.png
  - id: detail
    category: 改进
    summary: "详情页新增阶段配速图"
    detail: |
      跑步详情页在核心数据下方新增阶段配速柱状图，点柱子能看每一段的配速。换手机或重装后从云端读回的记录也能看到。
    images:
      - detail.png
  - id: records
    category: 改进
    summary: "记录页重新排版"
    detail: |
      记录按月份分组，显示每月的距离、次数和卡路里；每条记录标出是否已同步，还没上传的可以一键「立即同步」。排行榜也换上了新配色。
    images:
      - history.png
  - id: goal-bests
    category: 新功能
    summary: "年度目标与个人最佳"
    detail: |
      「我」页可以设定今年的跑量目标并查看进度，还会自动算出你的 5 公里、10 公里最佳成绩、最远一次和最快配速。
    images:
      - me.png
  - id: lockscreen-diagnosis
    category: 改进
    summary: "锁屏跑步诊断"
    detail: |
      重新做了锁屏跑步诊断：逐项检查定位、通知、自启动、省电策略等设置，如实显示哪些已开启、哪些需要处理，并能一键跳到对应的系统设置。
    images:
      - diagnosis.png
  - id: offline
    category: 改进
    summary: "断网时更安心"
    detail: |
      - 断网结束跑步会立即保存到手机并明确告诉你，联网后自动上传
      - 登录状态下也能看到手机上还没上传的记录
      - 退出登录时会保留还没上传的记录，重新登录后再上传；换账号登录也不会传错人
      - 断网登录时如实提示网络问题，不再误报「邮箱或密码错误」
  - id: login-register
    category: 改进
    summary: "登录与注册页焕新"
    detail: |
      登录、注册页按新设计重新排版，支持「密码登录 / 验证码登录」切换。
  - id: stability
    category: 修复
    summary: "若干问题修复"
    detail: |
      - 修复游客身份进入时被误判「会话已过期」的问题
      - 正常结束的跑步不再被误报为「上次跑步可能被中断」
      - 跑前和跑步中的 GPS 状态判断保持一致，室外信号好时不再误显示「信号弱」
---
