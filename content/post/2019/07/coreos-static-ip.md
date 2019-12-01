---
title: "CoreOS Static Ip 固定 IP 設定"
date: 2019-07-24T17:01:37+08:00
draft: false
tags: ["coreos"]
---

## 設定 static ip

副檔名必須是.network  

`$ vi /etc/systemd/network/enp0s8.network`

```
[Match]
Name=enp0s8
 
[Network]
Address=192.168.56.201/24
```

![static ip](https://fblog.ooopiz.com/images/2019/07/a001.jpg "static ip")

## reboot

`sudo reboot`
