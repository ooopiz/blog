---
title: 'CentOS6.5 安裝Nginx'
date: 2015-08-24T07:01:01+08:00
draft: false
tags: ["nginx"]
---

## 新增 Nginx 官方所提供的第三方套件庫

新增一個檔案 `/etc/yum.repos.d/nginx.repo` 內容如下

```ini
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/centos/$releasever/$basearch/
gpgcheck=0
enabled=1
```

## 更新套件庫

`yum update -y`

## 安裝 Nginx

`yum install nginx`

## 執行 Nginx

`service nginx start`

## 開機時自動啟動

`sudo chkconfig --levels 235 nginx on`
