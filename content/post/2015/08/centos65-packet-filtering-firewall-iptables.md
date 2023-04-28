---
title: 'CentOS 6.5 防火牆設定iptables'
date: 2015-08-21T10:05:01+08:00
draft: false
tags: ["centos", "iptables"]
---

CentOS一般預設開啟的只有SSH的Port 22，如果有其他的需求就必須手動設定防火牆。
比較常用的Port..

## 常見的預設 port 號
| Service | Port |
| --- | --- |
| FTP | 21 |
| SSH | 22 |
| HTTP  |  80 |
| HTTPS | 443 |
| MYSQL | 3306 |


## 將對應的資訊加入iptables設定檔中

/etc/sysconfig/iptables

```
-A INPUT -m state --state NEW -m tcp -p tcp --dport 21 -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 22 -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 80 -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 3306 -j ACCEPT
```

![](https://fblog.ooopiz.com/images/201508/001.png)

## 設定完iptables記得必須重新啟動防火牆

`service iptables restart`

或

`/etc/init.d/iptables restart`

## 查看有打開的Port

`netstat -tnlp`

`netstat -tlp`
