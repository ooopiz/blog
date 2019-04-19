---
title: 'yum 和 wget 使用 proxy'
date: 2015-09-02T17:05:01+08:00
draft: false
---
### yum 設定檔
在設定檔中加入以下參數config /etc/yum.conf

```
# The proxy server - proxy server:port number
http_proxy = proxy.xxxxxx.com.tw:3128
# The account details for yum connections
proxy_username=user_name
proxy_password=user_password
```

>此設定參數可提供所有帳號使用
>若要針對特定帳號使用，可以將下列參數加入到 ~/.bash_profile
>(*有空再研究*)

### wget
在設定檔中加入以下參數config /etc/wgetrc

```
http_proxy = proxy.xxxxxx.com.tw:3128
use_proxy = on
wait = 15
```

---

<b style="color:red;">Error: Cannot retrieve metalink for repository: epel. Please verify its path and try again</b>

解決方法：

編輯[epel]下的baseurl前的#號去掉，mirrorlist前添加#号。正確配置如下：
config /etc/yum.repos.d/epel.repo
```
[epel]
name=Extra Packages for Enterprise Linux 6 - $basearch
baseurl=http://download.fedoraproject.org/pub/epel/6/$basearch
#mirrorlist=https://mirrors.fedoraproject.org/metalink?repo=epel-6&arch=$basearch
failovermethod=priority
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6
```
