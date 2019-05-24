---
title: '安裝 Nginx 1.9+'
date: 2016-05-05T02:47:01+08:00
draft: false
tags: ["nginx"]
---
### 新增nginx.repo

`# vi /etc/yum.repos.d/nginx.repo`

```config nginx.repo
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/mainline/centos/$releasever/$basearch/
gpgcheck=0
enabled=1
```

### 安裝Nginx
`# yum install nginx`

### 啟動服務
`# service nginx start`
  
`# chkconfig --levels 235 nginx on`
