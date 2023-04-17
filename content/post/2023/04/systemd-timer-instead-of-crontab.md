---
title: "Systemd Timer 執行秒級排程，可替代 crontab"
date: 2023-04-15T00:39:44+08:00
draft: false
tags: ["systemd"]
---

## crontab 每 30 秒執行

大家應該都有用過 crontab 的經驗吧？  
crontab 每次執行的最小單位就是分鐘，如果遇到秒級需求的任務排程。  
很常見到類似底下的 crontab 的設定。  

設定上相當方便，不過我們可以認識一下另一種 systemd timer 的作法。  
或是你可以想像一下，如果 5秒要執行一次，crontab 會長什麼樣子。

```bash
* * * * *  dosomething
* * * * *  sleep 30; dosomething
```

## systemd timer 特點

1. 使用 timer 來執行 service，可以避免上一個任務還沒進行完，又開始一個新的任務。

## systemd timer

### jobqueue.service / systemd service file

建立一個 jobqueue.service 設定檔，內容如下:

```ini
[Unit]
Description=Execute jobqueue

[Service]
Type=simple
ExecStart=/bin/bash -c '/usr/bin/date >> /tmp/date.log'
```

建立完成後重載一下 `systemctl daemon-reload`

接著當你執行 `systemctl start jobqueue.service` 時，就會執行一次 ExecStart 的命令

### jobqueue.timer / systemd timer file

建立一個 jobqueue.timer 設定檔，內容如下：

```ini
[Unit]
Description=Run jobqueue on calendar

[Timer]
Unit=jobqueue.service
OnCalendar=*-*-* *:*:00,30
AccuracySec=1s

[Install]
WantedBy=multi-user.target
```

這邊範例使用 OnCalendar 參數，意思是時間 00秒跟 30秒的時候執行，  
當然也有其它數秒的方式，這邊就先不介紹了。

另外如果你設定的是秒級的任務，需調整時間精準度 AccuracySec=1s (預設是分)

建立完成後重載一下 `systemctl daemon-reload`

### 啟動排程

`systemctl start jobqueue.timer`

如果你需要下次重新開機時自動啟動這個 timer 記得:

`systemctl enable jobqueue.timer`

### 查看有哪些 timer 正在執行

`systemctl list-timers --all`

![systemctl list-timers](https://fblog.ooopiz.com/images/2023/04/b001.png)

* NEXT: 下次執行時間
* LEFT: 距離下次要執行還有多久
* LAST: 上次執行時間
* PASSED: 距離上次執行已經過了多久

### 執行結果

再來 /tmp/date.log 看看，就可以看到每 30 秒，按時輸出的結果了。

![output](https://fblog.ooopiz.com/images/2023/04/b002.png)
