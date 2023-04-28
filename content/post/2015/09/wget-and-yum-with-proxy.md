---
title: 'yum 和 wget 使用 proxy'
date: 2015-09-02T17:05:01+08:00
draft: false
tags: ["centos"]
---

## yum 設定檔

在設定檔中加入以下參數 config /etc/yum.conf

```ini
# The proxy server - proxy server:port number
http_proxy = proxy.xxxxxx.com.tw:3128

# The account details for yum connections
proxy_username=user_name
proxy_password=user_password
```

> 此設定參數可提供所有帳號使用  
> 若要針對特定帳號使用，可以將下列參數加入到 ~/.bash_profile  
> (*有空再研究*)

## wget

在設定檔中加入以下參數 config /etc/wgetrc

```ini
http_proxy = proxy.xxxxxx.com.tw:3128
use_proxy = on
wait = 15
```