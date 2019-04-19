---
title: '2016/07/27 使用ab壓測'
date: 2016-07-29T01:16:01+08:00
draft: false
---
## 2016/07/27 使用ab壓測

覺得ab壓出的不是很準，但還是紀錄一下

### 環境說明
- 主機：MacPro裡的VM
- CPU : 1
- Memory：512M
- 系統：CentOS 7
- 網頁服務：Nginx/1.11.1

---

### 開始進行壓力測試
`# ab -n 1000 -c 500 -k http://127.0.0.1/`

<div style="color:blue">
當擴大到2000併發時遇到 socket: Too many open files (24) 的問題
</div>

`# ab -n 10000 -c 2000 -k http://127.0.0.1/`

<img desc="" src="//fblog.loopbai.com/images/201607/A07-01.png">

<div style="color:blue">
Google後了解是系統設定的限制
</div>

#### 查看目前系統設定的限制 (ulimit -a # 可查看全部參數)

`# su nginx -`
> 如果su 無法切換使用者可能需要修改一下`vipw`

#### 查可開啟的數量
`# ulimit -n`

#### 修改可打開的文件數

`# vi /etc/security/limits.conf`

星號代表全局，soft軟體，hard硬體，nofile指的是可打開的文件數

```
nginx soft nofile 65536
nginx hard nofile 65536
```

```
* soft nofile 65536
* hard nofile 65536
```

