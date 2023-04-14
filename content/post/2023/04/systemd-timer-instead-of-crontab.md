---
title: "Systemd Timer 執行秒級排程，可替代 crontab"
date: 2023-04-15T00:39:44+08:00
draft: false
tags: ["systemd"]
---

## crontab 每 30 秒執行

大家應該都有用過 crontab 的經驗吧？ 但 crontab 每次執行的最小單位就是分鐘，  
如果遇到有秒級需求的排程任務需要進行。很常見到類似底下的 crontab 的設定。  
設定上相當方便，不過我們可以認識一下另一種 systemd timer 的作法。

```bash
* * * * *  dosomething
* * * * *  sleep 30; dosomething
```

## systemd timer

### systemd service file

```ini
[Unit]
Description=Execute dudu jobqueue

[Service]
Type=simple
ExecStart=/bin/bash -c '/usr/bin/date >> /123.log'
```

### systemd timer file

```ini
[Unit]
Description=Run jobqueue on calendar

[Timer]
OnCalendar=*-*-* *:*:00,30
Unit=jobqueue.service
AccuracySec=1s

[Install]
WantedBy=multi-user.target
```

如果是秒級的需調整時間精準度 AccuracySec

### 啟動排程

`systemctl start jobqueue.timer`

### 查看有哪些 timer 正在執行

`systemctl list-timers`
